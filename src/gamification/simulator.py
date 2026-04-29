from __future__ import annotations

from dataclasses import asdict
from typing import Dict, List, Optional

from .engine import GamificationEngine
from .models import Merchant, PaymentReceipt, ScanNotification, User


class GamificationSimulator:
    """High-level simulation layer (no real QR backend required).

    The 'click_qr' action simulates staff scanning and runs downstream effects.
    """

    def __init__(self, engine: GamificationEngine) -> None:
        self.engine = engine
        self.users: Dict[str, User] = {}
        self.merchants: Dict[str, Merchant] = {}
        self.notifications: List[ScanNotification] = []

    def add_user(self, user: User) -> None:
        self.users[user.id] = user

    def add_merchant(self, merchant: Merchant) -> None:
        self.merchants[merchant.id] = merchant

    def click_qr(self, *, customer_id: str, supervisor_id: str, event_id: str) -> ScanNotification:
        token = self.engine.generate_qr_token(customer_id, event_id)
        result = self.engine.checkin_scan(event_id=event_id, staff_user_id=supervisor_id, qr_token=token)
        note = ScanNotification(
            supervisor_id=supervisor_id,
            event_id=event_id,
            customer_id=customer_id,
            status=result.status,
            message=result.message,
        )
        self.notifications.append(note)
        return note

    def pay_with_optional_voucher(
        self,
        *,
        customer_id: str,
        merchant_id: str,
        gross_amount: float,
        voucher_code: Optional[str] = None,
        points_per_euro: int = 2,
    ) -> PaymentReceipt:
        customer = self.users[customer_id]
        merchant = self.merchants[merchant_id]

        discount = 0.0
        if voucher_code:
            voucher = self.engine.vouchers.get(voucher_code)
            if voucher and voucher["status"] == "issued":
                if voucher["reward_type"] == "percentage_discount":
                    discount = round(gross_amount * (voucher["reward_value"] / 100.0), 2)
                if self.engine.redeem_voucher(code=voucher_code, merchant_id=merchant_id):
                    pass
                else:
                    discount = 0.0
            else:
                voucher_code = None

        net = round(max(gross_amount - discount, 0.0), 2)
        customer.cash_balance = round(customer.cash_balance - net, 2)
        merchant.cash_balance = round(merchant.cash_balance + net, 2)

        earned_points = int(net * points_per_euro)
        self.engine.award_activity_points(
            user_id=customer_id,
            points=earned_points,
            source_type="booking",
            source_id=f"payment:{merchant_id}",
            idempotency_key=f"payment:{customer_id}:{merchant_id}:{gross_amount}:{voucher_code or 'none'}",
        )

        return PaymentReceipt(
            customer_id=customer_id,
            merchant_id=merchant_id,
            gross_amount=gross_amount,
            discount_amount=discount,
            net_amount=net,
            voucher_code=voucher_code,
            points_earned=earned_points,
            metadata={
                "customer_balance": customer.cash_balance,
                "merchant_balance": merchant.cash_balance,
            },
        )

    def get_notifications(self) -> List[dict]:
        return [asdict(n) for n in self.notifications]
