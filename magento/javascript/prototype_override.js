//source: /workspace/coverbrands/skin/frontend/default/coverbrands/js/coverbrands-quickcheckout.js


QuickCheckout.prototype.initialize = function() {
    this.reloadPaymentMethodsFlag = true;

    this.place_order_button_disabled = 0;
    this.lastSuccefulShipping = null;
    // Save checkout method as register if customer is not logged in
    if ($('register-customer-password')) {
        checkout.method = 'customer';
        this.saveCheckoutMethod('customer');
    }

    this.addEventListenersToShowAndHideLoginLinks();

    // Add event listener to "Create customer account" checkbox
    var createCustomerCheckbox = $('billing:id_create_account');
    if (createCustomerCheckbox) {
        var $this = this;
        jQuery('.billing_id_create_account').change(function() {
            $this.onCustomCheckboxChange(createCustomerCheckbox, 'create_account');
        });
    }

    // Add event listener to "SMS Subscription" checkbox
    var smsSubscriptionCheckbox = $('billing:sms_subscription');
    if (smsSubscriptionCheckbox) {
        var $this = this;
        jQuery('.billing_sms_subscription').change(function() {
            $this.onCustomCheckboxChange(smsSubscriptionCheckbox, 'sms_subscription');
        });
    }

    // Add event listener to "Subscribe to newsletter" checkbox
    var newsletterSubscriptionCheckbox = $('billing:id_subscribe_newsletter');
    if (newsletterSubscriptionCheckbox) {
        var $this = this;
        jQuery('.billing_subscribe_newsletter').change(function() {
            $this.onCustomCheckboxChange(newsletterSubscriptionCheckbox, 'subscribe_newsletter');
        });
    }

    // Add event listener to country select
    if ($('billing:country_id')) {
        $('billing:country_id').observe('change', this.onBillingCountryChange.bindAsEventListener(this));

        if (!$F('billing:country_id')) {
            this.selectFirstCountry();
        }
    }
    if ($('shipping:country_id')) {
        $('shipping:country_id').observe('change', this.onShippingCountryChange.bindAsEventListener(this));

        if (!$F('shipping:country_id')) {
            this.selectFirstCountry();
        }
    }

    // Add event listener to region select
    if ($('billing:region_id')) {
        $('billing:region_id').observe('change', this.onBillingRegionChange.bindAsEventListener(this));
    }
    if ($('shipping:region_id')) {
        $('shipping:region_id').observe('change', this.onShippingRegionChange.bindAsEventListener(this));
    }

    // Add event listener to postcode-field
    if ($('billing:postcode')) {
        $('billing:postcode').observe('blur', this.onPostcodeBlur.bindAsEventListener(this));
    }
    if ($('shipping:postcode')) {
        $('shipping:postcode').observe('blur', this.onPostcodeBlur.bindAsEventListener(this));
    }

    // Add event listener to eventual preloaded addresses
    if ($('billing-address-select')) {
        $('billing-address-select').observe('change', this.onPreloadedBillingAdressChange.bindAsEventListener(this));
    }
    if ($('shipping-address-select')) {
        $('shipping-address-select').observe('change', this.onPreloadedShippingAdressChange.bindAsEventListener(this));
    }

    this.addEventListenersToShippingChoiceRadios();
    this.onShippingSameAsBillingClick();

    // Start by reloading shipping methods
    this.reloadShippingMethods();

    // JS hook available for other js to reload QuickCheckout
    document.observe('quickcheckout:reload', this.reloadShippingMethods.bind(this));
    document.observe('quickcheckout:shippingload_after', this.afterShippingLoad.bind(this));
    document.observe('payment-method:switched', this.onPaymentSwitchFire.bind(this));

    // EE customer balance specific
    if ($('use_customer_balance') && Payment.prototype.switchCustomerBalanceCheckbox) {
        document.observe('quickcheckout:paymentload_after', function ()
        {
            payment.switchCustomerBalanceCheckbox();
        });
    }
    try {
        if (qcDefaultBillingAddress != false && qcDefaultShippingAddress != false) {
            this.autoFillAddressFields(qcDefaultBillingAddress, qcDefaultShippingAddress);
        }
    }
    catch (e) {
        response = {};
    }

    this.removeMagentoHtmlElements();
};
