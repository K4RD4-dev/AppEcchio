import unittest

from src.gamification import GamificationEngine


class GamificationEngineTest(unittest.TestCase):
    def setUp(self) -> None:
        self.engine = GamificationEngine(secret_key="dev-secret", checkin_points=600)
        self.user = "u1"
        self.event = "e1"
        self.staff = "s1"
        self.engine.register_user_to_event(self.user, self.event)
        self.engine.authorize_staff_for_event(self.staff, self.event)

    def test_valid_checkin_awards_points_and_issues_voucher(self):
        token = self.engine.generate_qr_token(self.user, self.event, ttl_seconds=120)
        result = self.engine.checkin_scan(event_id=self.event, staff_user_id=self.staff, qr_token=token)
        self.assertEqual(result.status, "valid")
        self.assertEqual(result.points_awarded, 600)

        wallet = self.engine.get_user_points(self.user)
        self.assertEqual(wallet["balance"], 600)

        vouchers = self.engine.get_user_vouchers(self.user)
        self.assertEqual(len(vouchers), 1)
        self.assertEqual(vouchers[0]["status"], "issued")

    def test_double_checkin_is_blocked(self):
        token = self.engine.generate_qr_token(self.user, self.event, ttl_seconds=120)
        first = self.engine.checkin_scan(event_id=self.event, staff_user_id=self.staff, qr_token=token)
        second = self.engine.checkin_scan(event_id=self.event, staff_user_id=self.staff, qr_token=token)

        self.assertEqual(first.status, "valid")
        self.assertEqual(second.status, "already_checked_in")
        self.assertEqual(len(self.engine.get_user_ledger(self.user)), 1)

    def test_unauthorized_staff_rejected(self):
        token = self.engine.generate_qr_token(self.user, self.event, ttl_seconds=120)
        result = self.engine.checkin_scan(event_id=self.event, staff_user_id="s2", qr_token=token)
        self.assertEqual(result.status, "not_authorized")

    def test_redeem_voucher_once(self):
        token = self.engine.generate_qr_token(self.user, self.event, ttl_seconds=120)
        self.engine.checkin_scan(event_id=self.event, staff_user_id=self.staff, qr_token=token)
        voucher = self.engine.get_user_vouchers(self.user)[0]

        ok1 = self.engine.redeem_voucher(code=voucher["code"], merchant_id="m1")
        ok2 = self.engine.redeem_voucher(code=voucher["code"], merchant_id="m1")

        self.assertTrue(ok1)
        self.assertFalse(ok2)


if __name__ == "__main__":
    unittest.main()
