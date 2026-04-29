const state = {
  points: 0,
  ledger: [],
  vouchers: [],
  notifications: [],
};

const CHECKIN_REWARD = 120;
const THRESHOLDS = [500, 1000];

function addLedger(label, delta) {
  state.ledger.unshift({ label, delta, at: new Date().toLocaleTimeString() });
}

function addPoints(amount, sourceLabel) {
  state.points += amount;
  addLedger(sourceLabel, `+${amount}`);
  render();
}

function spendPoints(amount, sourceLabel) {
  state.points = Math.max(state.points - amount, 0);
  addLedger(sourceLabel, `-${amount}`);
  render();
}

function getNextThreshold() {
  return THRESHOLDS.find((t) => t > state.points) || THRESHOLDS[THRESHOLDS.length - 1];
}

function simulateCheckin() {
  const status = "valid";
  const notification = {
    at: new Date().toLocaleTimeString(),
    status,
    message: "Codice cliccato: presenza verificata e token assegnati.",
  };
  state.notifications.unshift(notification);
  addPoints(CHECKIN_REWARD, "Check-in evento");
}

function buyDiscount(cost, label, percentage) {
  if (state.points < cost) {
    alert("Token insufficienti");
    return;
  }
  spendPoints(cost, `Riscatto ${label}`);
  const code = `VCH-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
  state.vouchers.unshift({ code, label, percentage, status: "attivo" });
  render();
}

function render() {
  document.getElementById("headerPoints").textContent = state.points;
  document.getElementById("homePoints").textContent = state.points;
  document.getElementById("profilePoints").textContent = state.points;

  const next = getNextThreshold();
  document.getElementById("nextThreshold").textContent = next;
  const progress = document.getElementById("thresholdProgress");
  progress.max = next;
  progress.value = state.points;

  document.getElementById("ledgerList").innerHTML = state.ledger
    .map((entry) => `<li>[${entry.at}] ${entry.label}: <strong>${entry.delta}</strong></li>`)
    .join("");

  document.getElementById("voucherList").innerHTML =
    state.vouchers.length === 0
      ? "<li>Nessun voucher disponibile</li>"
      : state.vouchers.map((v) => `<li>${v.label} (${v.percentage}%) - Codice: <strong>${v.code}</strong></li>`).join("");

  document.getElementById("notifications").innerHTML =
    state.notifications.length === 0
      ? "<li>Nessuna scansione/click registrata</li>"
      : state.notifications
          .map((n) => `<li>[${n.at}] ${n.status}: ${n.message}</li>`)
          .join("");
}

function initTabs() {
  document.querySelectorAll(".tab").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".tab").forEach((t) => t.classList.remove("active"));
      document.querySelectorAll(".panel").forEach((p) => p.classList.remove("active"));
      btn.classList.add("active");
      document.getElementById(btn.dataset.tab).classList.add("active");
    });
  });
}

document.getElementById("simulateCheckin").addEventListener("click", simulateCheckin);
document.getElementById("buy5").addEventListener("click", () => buyDiscount(500, "Sconto 5%", 5));
document.getElementById("buy10").addEventListener("click", () => buyDiscount(1000, "Sconto 10%", 10));

initTabs();
render();
