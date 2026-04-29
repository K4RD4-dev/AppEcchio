const STORAGE_KEY = "appecchio_gamification_state_v1";

const state = loadState() || {
  points: 0,
  ledger: [],
  vouchers: [],
  notifications: [],
  customerBalance: 120.0,
  merchantBalance: 0.0,
  lastReceipt: null,
};

const CHECKIN_REWARD = 120;
const THRESHOLDS = [500, 1000];

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

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
  const notification = {
    at: new Date().toLocaleTimeString(),
    status: "valid",
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

function runCheckout() {
  const gross = Number(document.getElementById("checkoutAmount").value || 0);
  const voucherCode = document.getElementById("checkoutVoucher").value;
  let discount = 0;

  if (voucherCode) {
    const voucher = state.vouchers.find((v) => v.code === voucherCode && v.status === "attivo");
    if (voucher) {
      discount = Number((gross * (voucher.percentage / 100)).toFixed(2));
      voucher.status = "usato";
      addLedger(`Voucher ${voucher.label} usato`, "0");
    }
  }

  const net = Number(Math.max(gross - discount, 0).toFixed(2));
  state.customerBalance = Number((state.customerBalance - net).toFixed(2));
  state.merchantBalance = Number((state.merchantBalance + net).toFixed(2));

  const earnedPoints = Math.floor(net * 2);
  addPoints(earnedPoints, "Punti da acquisto");

  state.lastReceipt = {
    gross,
    discount,
    net,
    earnedPoints,
    voucherCode: voucherCode || null,
    customerBalance: state.customerBalance,
    merchantBalance: state.merchantBalance,
    at: new Date().toLocaleTimeString(),
  };

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
      : state.vouchers
          .map((v) => `<li>${v.label} (${v.percentage}%) - Codice: <strong>${v.code}</strong> - Stato: ${v.status}</li>`)
          .join("");

  document.getElementById("notifications").innerHTML =
    state.notifications.length === 0
      ? "<li>Nessuna scansione/click registrata</li>"
      : state.notifications.map((n) => `<li>[${n.at}] ${n.status}: ${n.message}</li>`).join("");

  const checkoutVoucher = document.getElementById("checkoutVoucher");
  checkoutVoucher.innerHTML = '<option value="">Nessuno</option>' +
    state.vouchers
      .filter((v) => v.status === "attivo")
      .map((v) => `<option value="${v.code}">${v.label} - ${v.code}</option>`)
      .join("");

  document.getElementById("receiptBox").textContent = state.lastReceipt
    ? JSON.stringify(state.lastReceipt, null, 2)
    : "Nessun pagamento eseguito";

  saveState();
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
document.getElementById("payNow").addEventListener("click", runCheckout);

initTabs();
render();
