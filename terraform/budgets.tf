# ---------------------------------------------------------------------------
# Subscription-level budget with configurable alert thresholds
# ---------------------------------------------------------------------------

resource "azurerm_consumption_budget_subscription" "landing_zone" {
  name            = "budget-${local.name_prefix}"
  subscription_id = "/subscriptions/${var.subscription_id}"

  amount     = var.budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
    # end_date is intentionally omitted so the budget auto-renews monthly
  }

  dynamic "notification" {
    for_each = var.budget_alert_thresholds

    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThanOrEqualTo"
      threshold_type = "Actual"

      contact_emails = var.budget_alert_emails
    }
  }

  lifecycle {
    # Prevent the budget from being re-created on every plan because
    # formatdate(timestamp()) always produces a new value.
    ignore_changes = [time_period]
  }
}
