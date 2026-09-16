import 'app_colors.dart';

/// COLOR SYSTEM
/// MINT   (#8FDDAA) = LIFE / SURVIVAL — runway, cash, stable, charge bar
/// PINK   (#E8829E) = COST / BURN — outflow, expense, critical, liabilities  
/// PURPLE            = SUBSCRIPTIONS ONLY
/// BLUE              = UI CHROME — borders, accents, structural
/// WHITE/SMOKE       = ALL OTHER NUMBERS — neutral facts
abstract final class SC {
  // ── Primary meanings ──────────────────────────
  static const life    = AppColors.neonGreen;   // mint — survival
  static const cost    = AppColors.hotPink;     // pink — burn/outflow
  static const subscr  = AppColors.purple;      // purple — subscriptions only
  static const chrome  = AppColors.turkishBlue; // blue — UI structure

  // ── Numbers ───────────────────────────────────
  static const numberPrimary  = AppColors.textPrimary; // smoke white — neutral facts
  static const numberLife     = AppColors.neonGreen;   // mint — cash, runway
  static const numberCost     = AppColors.hotPink;     // pink — outflows
  static const numberSubscr   = AppColors.purple;      // purple — subscriptions

  // ── Status ────────────────────────────────────
  static const statusStable   = AppColors.neonGreen;
  static const statusCaution  = AppColors.amber;
  static const statusCritical = AppColors.hotPink;

  // ── Section accents (thin left bar) ──────────
  static const accentLife         = AppColors.neonGreen;   // metrics, config
  static const accentCost         = AppColors.gold;        // liabilities — gold
  static const accentSubscription = AppColors.purple;      // subscriptions only
  static const accentNeutral      = AppColors.turkishBlue; // investable, timeline, sim

  // ── Transaction icons ─────────────────────────
  static const txExpense        = AppColors.hotPink;
  static const txIncome         = AppColors.neonGreen;
  static const txLoan           = AppColors.turkishBlue;
  static const txInvestment     = AppColors.purple;
  static const txRepayment      = AppColors.gold;
  static const txOpeningBalance = AppColors.turkishBlue;

  // ── Buttons ───────────────────────────────────
  static const btnPrimary     = AppColors.neonGreen;
  static const btnDestructive = AppColors.hotPink;
  static const btnLoan        = AppColors.gold;

  // ── Specific metrics ──────────────────────────
  static const metricCash       = numberLife;     // mint — cash is life
  static const metricRunway     = numberLife;     // mint — overridden by status
  static const metricTotal      = numberCost;     // pink — total outflow
  static const metricBurnRate   = numberCost;     // pink — burn
  static const metricBudget     = numberCost;     // pink — budget outflow
  static const metricDebt       = AppColors.gold;  // gold — obligation/weight
  static const metricSubscr     = numberSubscr;   // purple — subscriptions
  static const metricInvestable = numberPrimary;  // white — neutral fact
  static const metricSafety     = numberPrimary;  // white — neutral fact
  static const metricRunOut     = AppColors.textSecondary;

  // ── UI ────────────────────────────────────────
  static const labelColor   = AppColors.textSecondary;
  static const captionColor = AppColors.textDim;
  static const dividerColor = AppColors.cardBorder;
}
