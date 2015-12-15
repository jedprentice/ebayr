# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ostruct'
require 'ebayr/response'
describe Ebayr::Response do
  it "builds objects from XML" do
    xml = "<GetSomethingResponse><Foo>Bar</Foo></GetSomethingResponse>"
    response = Ebayr::Response.new(
      OpenStruct.new(:command => 'GetSomething'),
      OpenStruct.new(:body => xml))
    response['Foo'].must_equal 'Bar'
    response.foo.must_equal 'Bar'
  end
  it "handes responses" do
    xml = "<GeteBayResponse><eBayFoo>Bar</eBayFoo></GeteBayResponse>"
    response = Ebayr::Response.new(
      OpenStruct.new(:command => 'GeteBay'),
      OpenStruct.new(:body => xml))
    response.ebay_foo.must_equal 'Bar'
  end
  it "handles responses with many html entities" do
    xml = "<GeteBayResponse><eBayFoo>Bar</eBayFoo><Description>#{'<p class="p1"><span class="s1"><br/></span></p>' * 5000}</Description></GeteBayResponse>"
    response = Ebayr::Response.new(
        OpenStruct.new(:command => 'GeteBay'),
        OpenStruct.new(:body => xml))
    response.ebay_foo.must_equal 'Bar'
  end

  it 'exposes (nested) attributes' do
    xml = <<-XML
      <GetSellerTransactionsResponse>
        <TransactionArray>
          <Transaction>
            <AmountPaid currencyID="USD">50.89</AmountPaid>
            <AdjustmentAmount currencyID="USD">0.0</AdjustmentAmount>
            <ConvertedAdjustmentAmount currencyID="USD">0.0</ConvertedAdjustmentAmount>
            <ShippingDetails>
              <ChangePaymentInstructions>true</ChangePaymentInstructions>
              <PaymentEdited>true</PaymentEdited>
              <PaymentInstructions>To checkout, please click on the eBay checkout Pay Now button</PaymentInstructions>
              <SalesTax>
                <SalesTaxPercent>0.0</SalesTaxPercent>
                <ShippingIncludedInTax>false</ShippingIncludedInTax>
                <SalesTaxAmount currencyID="USD">1.1</SalesTaxAmount>
              </SalesTax>
            </ShippingDetails>
          </Transaction>
        </TransactionArray>
      </GetSellerTransactionsResponse>
    XML

    response = Ebayr::Response.new(
      OpenStruct.new(command: 'GetSellerTransactions'),
      OpenStruct.new(body: xml)
    )
    assert_kind_of Hash, response.transaction_array
    response.transaction_array.transaction.amount_paid.must_equal '50.89'
    response.transaction_array.transaction.amount_paid_currency_id.must_equal 'USD'
  end

  def test_response_nesting
    xml = <<-XML
      <GetOrdersResponse>
        <OrdersArray>
          <Order>
            <OrderID>1</OrderID>
          </Order>
          <Order>
            <OrderID>2</OrderID>
          </Order>
          <Order>
            <OrderID>3</OrderID>
          </Order>
        </OrdersArray>
      </GetOrdersResponse>
    XML
    response = Ebayr::Response.new(
      OpenStruct.new(:command => 'GetOrders'),
      OpenStruct.new(:body => xml)
    )
    assert_kind_of Hash, response.orders_array
    response.orders_array.order[0].order_id.must_equal "1"
    response.orders_array.order[1].order_id.must_equal "2"
    response.orders_array.order[2].order_id.must_equal "3"
  end
end
