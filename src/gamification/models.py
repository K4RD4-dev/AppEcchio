from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal

UserRole = Literal["customer", "supervisor"]


@dataclass
class User:
    id: str
    role: UserRole
    display_name: str
    cash_balance: float = 0.0


@dataclass
class Merchant:
    id: str
    name: str
    cash_balance: float = 0.0


@dataclass
class ScanNotification:
    supervisor_id: str
    event_id: str
    customer_id: str
    status: str
    message: str


@dataclass
class PaymentReceipt:
    customer_id: str
    merchant_id: str
    gross_amount: float
    discount_amount: float
    net_amount: float
    voucher_code: str | None = None
    points_earned: int = 0
    metadata: dict = field(default_factory=dict)
