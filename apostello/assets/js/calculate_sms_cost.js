import $ from 'jquery';

export default function setCost(nPeople) {
  const smsLength = $('#id_content')[0].value.length;
  const nSms = Math.ceil(smsLength / 160);
  const cost = `\$${nPeople * nSms * 4 / 100}`;
  document.getElementById('#send').innerHTML = `Send (${cost})`;
}
