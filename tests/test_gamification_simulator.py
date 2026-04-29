import unittest

from src.gamification import GamificationEngine, GamificationSimulator, Merchant, User


class GamificationSimulatorTest(unittest.TestCase):
    def setUp(self) -> None:
        self.engine = GamificationEngine(secret_key="dev-secret", checkin_points=500)
        self.sim = GamificationSimulator(self.engine)

        self.customer = User(id="u1", role="customer", display_name="Mario", cash_balance=100.0)
        self.supervisor = User(id="s1", role="supervisor", display_name="Laura", cash_balance=0.0)
        self.merchant = Merchant(id="m1", name="Bar Centro", cash_balance=0.0)

        self.sim.add_user(self.customer)
        self.sim.add_user(self.supervisor)
        self.sim.add_merchant(self.merchant)

        self.engine.register_user_to_event("u1", "e1")
        self.engine.authorize_staff_for_event("s1", "e1")

    def test_click_qr_simulates_scan_and_notifies_supervisor(self):
        note = self.sim.click_qr(customer_id="u1", supervisor_id="s1", event_id="e1")
        self.assertEqual(note.status, "valid")
        self.assertEqual(len(self.sim.get_notifications()), 1)
        self.assertEqual(self.engine.get_user_points("u1")["balance"], 500)

    def test_payment_debits_customer_and_credits_merchant(self):
        receipt = self.sim.pay_with_optional_voucher(customer_id="u1", merchant_id="m1", gross_amount=10.0)
        self.assertEqual(receipt.net_amount, 10.0)
        self.assertEqual(receipt.points_earned, 20)
        self.assertEqual(self.sim.users["u1"].cash_balance, 90.0)
        self.assertEqual(self.sim.merchants["m1"].cash_balance, 10.0)

    def test_payment_with_voucher_applies_discount(self):
        self.sim.click_qr(customer_id="u1", supervisor_id="s1", event_id="e1")
        voucher_code = self.engine.get_user_vouchers("u1")[0]["code"]
        receipt = self.sim.pay_with_optional_voucher(
            customer_id="u1",
            merchant_id="m1",
            gross_amount=20.0,
            voucher_code=voucher_code,
        )
        self.assertEqual(receipt.discount_amount, 1.0)  # 5%
        self.assertEqual(receipt.net_amount, 19.0)
        self.assertEqual(self.sim.users["u1"].cash_balance, 81.0)
        self.assertEqual(self.sim.merchants["m1"].cash_balance, 19.0)


if __name__ == "__main__":
    unittest.main()
