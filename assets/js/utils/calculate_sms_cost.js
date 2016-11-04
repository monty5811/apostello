import $ from 'jquery';

export default function setCost(nPeople, sCost) {
  const smsLength = $('#id_content')[0].value.length;
  const nSms = Math.ceil(smsLength / 160);
  const cost = `$${(nPeople * nSms * sCost).toFixed(2)}`;
  document.getElementById('#send').innerHTML = `Send (${cost})`;
}
