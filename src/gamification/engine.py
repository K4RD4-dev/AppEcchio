from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import base64
import hashlib
import hmac
import json
import secrets
from typing import Dict, List, Optional, Set, Tuple


@dataclass(frozen=True)
class CheckinResult:
    status: str
    points_awarded: int = 0
    message: str = ""


class GamificationEngine:
    """In-memory MVP engine for points, check-ins and vouchers."""

    def __init__(self, secret_key: str, checkin_points: int = 50) -> None:
        self.secret_key = secret_key.encode("utf-8")
        self.checkin_points = checkin_points
        self.wallets: Dict[str, int] = {}
        self.ledger: List[dict] = []
        self.idempotency_keys: Set[str] = set()
        self.event_registrations: Set[Tuple[str, str]] = set()
        self.staff_authorizations: Set[Tuple[str, str]] = set()
        self.checkins: Set[Tuple[str, str]] = set()
        self.reward_tiers: List[Tuple[int, str, float]] = [(500, "percentage_discount", 5.0), (1000, "percentage_discount", 10.0)]
        self.vouchers: Dict[str, dict] = {}
        self.issued_tiers: Set[Tuple[str, int]] = set()

    def register_user_to_event(self, user_id: str, event_id: str) -> None:
        self.event_registrations.add((user_id, event_id))

    def authorize_staff_for_event(self, staff_user_id: str, event_id: str) -> None:
        self.staff_authorizations.add((staff_user_id, event_id))

    def generate_qr_token(self, user_id: str, event_id: str, ttl_seconds: int = 90) -> str:
        now = datetime.now(timezone.utc)
        payload = {
            "user_id": user_id,
            "event_id": event_id,
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(seconds=ttl_seconds)).timestamp()),
            "nonce": secrets.token_hex(8),
        }
        payload_raw = json.dumps(payload, separators=(",", ":")).encode("utf-8")
        payload_b64 = base64.urlsafe_b64encode(payload_raw).decode("utf-8")
        sig = hmac.new(self.secret_key, payload_b64.encode("utf-8"), hashlib.sha256).hexdigest()
        return f"{payload_b64}.{sig}"

    def _decode_and_verify_token(self, token: str) -> Optional[dict]:
        try:
            payload_b64, sig = token.rsplit(".", 1)
        except ValueError:
            return None
        expected = hmac.new(self.secret_key, payload_b64.encode("utf-8"), hashlib.sha256).hexdigest()
        if not hmac.compare_digest(sig, expected):
            return None
        try:
            payload_raw = base64.urlsafe_b64decode(payload_b64.encode("utf-8"))
            payload = json.loads(payload_raw.decode("utf-8"))
        except Exception:
            return None
        now_ts = int(datetime.now(timezone.utc).timestamp())
        if now_ts > int(payload.get("exp", 0)):
            return None
        return payload

    def checkin_scan(self, *, event_id: str, staff_user_id: str, qr_token: str) -> CheckinResult:
        payload = self._decode_and_verify_token(qr_token)
        if payload is None:
            return CheckinResult(status="token_invalid", message="Token non valido o scaduto")

        user_id = payload.get("user_id")
        token_event_id = payload.get("event_id")
        if token_event_id != event_id:
            return CheckinResult(status="token_invalid", message="Token non coerente con evento")

        if (staff_user_id, event_id) not in self.staff_authorizations:
            return CheckinResult(status="not_authorized", message="Staff non autorizzato")

        if (user_id, event_id) not in self.event_registrations:
            return CheckinResult(status="not_registered", message="Utente non registrato")

        if (user_id, event_id) in self.checkins:
            return CheckinResult(status="already_checked_in", message="Check-in già registrato")

        self.checkins.add((user_id, event_id))
        idempotency_key = f"checkin:{event_id}:{user_id}"
        points = self._award_points(user_id=user_id, points=self.checkin_points, source_type="event_checkin", source_id=event_id, idempotency_key=idempotency_key)
        self._issue_vouchers_if_threshold_met(user_id)
        return CheckinResult(status="valid", points_awarded=points, message="Check-in valido")

    def _award_points(self, *, user_id: str, points: int, source_type: str, source_id: str, idempotency_key: str) -> int:
        if idempotency_key in self.idempotency_keys:
            return 0
        self.idempotency_keys.add(idempotency_key)
        self.wallets[user_id] = self.wallets.get(user_id, 0) + points
        self.ledger.append(
            {
                "user_id": user_id,
                "source_type": source_type,
                "source_id": source_id,
                "points": points,
                "status": "confirmed",
                "idempotency_key": idempotency_key,
                "created_at": datetime.now(timezone.utc).isoformat(),
            }
        )
        return points

    def _issue_vouchers_if_threshold_met(self, user_id: str) -> None:
        balance = self.wallets.get(user_id, 0)
        for threshold, reward_type, reward_value in sorted(self.reward_tiers, key=lambda x: x[0]):
            tier_key = (user_id, threshold)
            if balance >= threshold and tier_key not in self.issued_tiers:
                code = f"VCH-{secrets.token_hex(4).upper()}"
                self.vouchers[code] = {
                    "code": code,
                    "user_id": user_id,
                    "threshold": threshold,
                    "reward_type": reward_type,
                    "reward_value": reward_value,
                    "status": "issued",
                    "issued_at": datetime.now(timezone.utc).isoformat(),
                }
                self.issued_tiers.add(tier_key)

    def get_user_points(self, user_id: str) -> dict:
        balance = self.wallets.get(user_id, 0)
        next_threshold = next((t for t, _, _ in sorted(self.reward_tiers) if t > balance), None)
        return {
            "user_id": user_id,
            "balance": balance,
            "next_threshold": next_threshold,
            "missing_points": None if next_threshold is None else next_threshold - balance,
        }

    def get_user_ledger(self, user_id: str) -> List[dict]:
        return [e for e in self.ledger if e["user_id"] == user_id]

    def get_user_vouchers(self, user_id: str) -> List[dict]:
        return [v for v in self.vouchers.values() if v["user_id"] == user_id]

    def redeem_voucher(self, *, code: str, merchant_id: str) -> bool:
        voucher = self.vouchers.get(code)
        if voucher is None or voucher["status"] != "issued":
            return False
        voucher["status"] = "redeemed"
        voucher["merchant_id"] = merchant_id
        voucher["redeemed_at"] = datetime.now(timezone.utc).isoformat()
        return True
