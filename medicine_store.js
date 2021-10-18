function calculateFinalPrice(selectObject) {
  itemIdIndex = selectObject.id.split('_').pop();
  $('#medicine_text_'+itemIdIndex).text($('#medicine_'+itemIdIndex + ' option:selected').text());
  $('#discount_percent_value_'+itemIdIndex).text($('#discount_percent_'+itemIdIndex).val());
  total_price = ($('#medicine_'+itemIdIndex).val() * $('#quantity_'+itemIdIndex).val());
  $('#total_price_'+itemIdIndex).text(total_price);
  discount = (total_price * $('#discount_percent_'+itemIdIndex).val()/100).toFixed(2);
  final_price = total_price - discount
  $('#final_price_'+itemIdIndex).text(final_price);
  $('#mrp_'+itemIdIndex).text($('#medicine_'+itemIdIndex).val());
  $('#discount_'+itemIdIndex).text(discount);
  generateFinalAmount();
}

function generateFinalAmount() {
  var total_amount = 0;
  $("[name='total_price']").each( function( i , e ) {
      var v = parseFloat( $( e ).text() );
      if ( !isNaN( v ) )
          total_amount += v;
  } );
  var total_discount_value = 0;
  $("[name='discount']").each( function( i , e ) {
      var v = parseFloat( $( e ).text() );
      if ( !isNaN( v ) )
          total_discount_value += v;
  } );
  var total_amount_payable = 0;
  $("[name='final_price']").each( function( i , e ) {
      var v = parseFloat( $( e ).text() );
      if ( !isNaN( v ) )
          total_amount_payable += v;
  } );
  $('#total_amount').text(total_amount);
  $('#total_discount_value').text(total_discount_value);
  $('#total_amount_payable').text(total_amount_payable);
}

function updateAllDiscounts() {
  $("[name='discount_percent']").val($('#discount_percent_main').val()).change();
}

function addNewItem() {
  var newId = $('#medicine_table tr').length;
  $('#medicine_table').append($('#newItemTemplate tr').clone());
  $('#medicine_table #serial_number_').attr('id',"serial_number_"+newId);
  $('#medicine_table #medicine_').attr('id',"medicine_"+newId);
  $('#medicine_table #medicine_text_').attr('id',"medicine_text_"+newId);
  $('#medicine_table #mrp_').attr('id',"mrp_"+newId);
  $('#medicine_table #quantity_').attr('id',"quantity_"+newId);
  $('#medicine_table #discount_percent_').attr('id',"discount_percent_"+newId);
  $('#medicine_table #total_price_').attr('id',"total_price_"+newId);
  $('#medicine_table #final_price_').attr('id',"final_price_"+newId);
  $('#medicine_table #discount_').attr('id',"discount_"+newId);
  $('#medicine_table #discount_percent_value_').attr('id',"discount_percent_value_"+newId);

  $('#serial_number_'+newId).text(newId);
  $('#discount_percent_'+newId).val($('#discount_percent_main').val());
  $('#discount_percent_value_'+newId).text($('#discount_percent_main').val());
  $('#medicine_text_'+newId).text($('#medicine_'+newId + ' option:selected').text());
}

function deleteItem(selectObject) {
  selectObject.closest('tr').remove();
  generateFinalAmount()
}

function printBill() {
  $('.dontPrint').hide();
  $('.onlyPrint').show();
}

function editBill() {
  $('.dontPrint').show();
  $('.onlyPrint').hide();
}

function setBillingDate() {
  todaysDate = new Date();
  $('#billingDate').text(todaysDate.toLocaleString());
}

$(document).ready(function() {
  addNewItem();
  setBillingDate();
});
