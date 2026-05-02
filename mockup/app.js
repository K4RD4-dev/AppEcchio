const STORAGE_KEY = "appecchio_gamification_state_v2";

const REWARD_TIERS = [
  { threshold: 500, label: "Sconto 5%", percentage: 5 },
  { threshold: 1000, label: "Sconto 10%", percentage: 10 },
];
const CHECKIN_XP = 120;

const state = loadState() || {
  tokens: 0,
  xp: 0,
  ledger: [],
  vouchers: [],
  notifications: [],
  customerBalance: 120.0,
  merchantBalance: 0.0,
  lastReceipt: null,
};

function tokensForExperience(xp) {
  if (xp <= 0) {
    return 0;
  }
  return Math.max(Math.ceil(xp / 10), 1);
}

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

function addLedger(label, { tokens = 0, xp = 0, note = "" } = {}) {
  state.ledger.unshift({
    label,
    tokens,
    xp,
    note,
    at: new Date().toLocaleTimeString(),
  });
}

function addProgress(xp, sourceLabel) {
  const tokens = tokensForExperience(xp);
  state.xp += xp;
  state.tokens += tokens;
  addLedger(sourceLabel, { tokens, xp });
  issueVouchersIfNeeded();
  render();
}

function getNextThreshold() {
  return REWARD_TIERS.find((tier) => tier.threshold > state.xp) || null;
}

function issueVouchersIfNeeded() {
  REWARD_TIERS.forEach((tier) => {
    const alreadyIssued = state.vouchers.some((voucher) => voucher.threshold === tier.threshold);
    if (state.xp < tier.threshold || alreadyIssued) {
      return;
    }
    const code = `VCH-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
    state.vouchers.unshift({
      code,
      label: tier.label,
      percentage: tier.percentage,
      threshold: tier.threshold,
      status: "attivo",
    });
    addLedger(`Voucher ${tier.label} sbloccato con XP`, { note: "premio" });
  });
}

function simulateCheckin() {
  const notification = {
    at: new Date().toLocaleTimeString(),
    status: "valid",
    message: `Codice cliccato: presenza verificata, +${tokensForExperience(CHECKIN_XP)} token e +${CHECKIN_XP} XP.`,
  };
  state.notifications.unshift(notification);
  addProgress(CHECKIN_XP, "Check-in evento");
}

function claimReward(threshold, label) {
  const tier = REWARD_TIERS.find((item) => item.threshold === threshold);
  if (!tier || state.xp < threshold) {
    alert("XP insufficienti");
    return;
  }
  issueVouchersIfNeeded();
  addLedger(`Controllo premio ${label}`, { note: "nessun consumo token" });
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
      addLedger(`Voucher ${voucher.label} usato`, { note: "redeem" });
    }
  }

  const net = Number(Math.max(gross - discount, 0).toFixed(2));
  state.customerBalance = Number((state.customerBalance - net).toFixed(2));
  state.merchantBalance = Number((state.merchantBalance + net).toFixed(2));

  const earnedXp = Math.floor(net * 2);
  addProgress(earnedXp, "XP e token da acquisto");

  state.lastReceipt = {
    gross,
    discount,
    net,
    earnedXp,
    earnedTokens: tokensForExperience(earnedXp),
    voucherCode: voucherCode || null,
    customerBalance: state.customerBalance,
    merchantBalance: state.merchantBalance,
    at: new Date().toLocaleTimeString(),
  };

  render();
}

function render() {
  document.getElementById("headerTokens").textContent = state.tokens;
  document.getElementById("headerXp").textContent = state.xp;
  document.getElementById("homeTokens").textContent = state.tokens;
  document.getElementById("homeXp").textContent = state.xp;
  document.getElementById("profileTokens").textContent = state.tokens;
  document.getElementById("profileXp").textContent = state.xp;

  const next = getNextThreshold();
  document.getElementById("nextThreshold").textContent = next ? next.threshold : "max";
  const progress = document.getElementById("thresholdProgress");
  progress.max = next ? next.threshold : state.xp || 1;
  progress.value = next ? state.xp : progress.max;

  document.getElementById("ledgerList").innerHTML = state.ledger
    .map((entry) => {
      const deltas = [
        entry.tokens ? `+${entry.tokens} token` : "",
        entry.xp ? `+${entry.xp} XP` : "",
        entry.note,
      ].filter(Boolean).join(" · ") || "0";
      return `<li>[${entry.at}] ${entry.label}: <strong>${deltas}</strong></li>`;
    })
    .join("");

  document.getElementById("voucherList").innerHTML =
    state.vouchers.length === 0
      ? "<li>Nessun voucher disponibile</li>"
      : state.vouchers
          .map((v) => `<li>${v.label} (${v.percentage}%) - ${v.threshold} XP - Codice: <strong>${v.code}</strong> - Stato: ${v.status}</li>`)
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
document.getElementById("buy5").addEventListener("click", () => claimReward(500, "Sconto 5%"));
document.getElementById("buy10").addEventListener("click", () => claimReward(1000, "Sconto 10%"));
document.getElementById("payNow").addEventListener("click", runCheckout);

initTabs();
render();
