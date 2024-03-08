---
title: Bonnes pratiques codestyle de JavaScript 
date: 2024-02-24 11:00:00
categories: [Fondement]
tags: [javascript, notions, noyau, codestyle]     # TAG names should always be lowercase
author: GoXLd
pin: false
published: false
---
  Модальное окно с отправкой данных в Google Таблицу
  <style>
    .recovery-button {
      display: inline-block;
      padding: 10px 20px;
      font-size: 16px;
      font-weight: bold;
      text-decoration: none;
      color: #fff;
      background-color: #A93D26;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      transition: background-color 0.3s ease;
    }
    .recovery-button:hover {
      background-color: #7C2B1A;
    }
    .recovery-button:active {
      transform: translateY(1px);
      box-shadow: 0 2px 2px rgba(0, 0, 0, 0.1);
    }
    .modal {
      display: none;
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 15%;
      height: 25%;
      background-color: rgba(0, 0, 0, 0.7);
      padding: 20px;
      border-radius: 5px;
      text-align: center;
      z-index: 1000;
    }
    .close {
      position: absolute;
      top: 10px;
      right: 10px;
      cursor: pointer;
      color: #fff;
    }

    #submitBtn {
      display: inline-block;
      padding: 10px 20px;
      font-size: 16px;
      font-weight: bold;
      text-decoration: none;
      color: #fff;
      background-color: #A93D26;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      transition: background-color 0.3s ease;
      margin-top: 20px;
    }
    #submitBtn:hover {
      background-color: #7C2B1A;
    }
    #submitBtn:active {
      transform: translateY(1px);
      box-shadow: 0 2px 2px rgba(0, 0, 0, 0.1);
    }
  </style>
<p><button id="myButton" class="recovery-button">RECOUPERER MES MOTS DE PASSE</button></p>
<!-- Модальное окно -->
<div id="myModal" class="modal">
  <span class="close">&times;</span>
  <p style="color: #fff;">SLOVO</p>
  <input type="text" id="inputField" placeholder="Введите текст" style="margin-bottom: 10px; padding: 5px; border-radius: 5px; border: 1px solid #ccc;">
  <br>
  <button id="submitBtn">Отправить</button>
</div>

<script>
  document.getElementById('myButton').addEventListener('click', function() {
    document.getElementById('myModal').style.display = 'block';
  });

  document.getElementsByClassName('close')[0].addEventListener('click', function() {
    document.getElementById('myModal').style.display = 'none';
  });

  document.getElementById('submitBtn').addEventListener('click', function() {
    var inputValue = document.getElementById('inputField').value;
    fetch('BUTTON_LINK_GS_POST', {
      method: 'POST',
      body: JSON.stringify({value: inputValue}),
      headers: {
        'Content-Type': 'application/json'
      }
    })
    .then(response => {
      if (response.ok) {
        alert('ОТПРАВЛЕНО');
        document.getElementById('myModal').style.display = 'none';
      } else {
        alert('Произошла ошибка при отправке данных');
      }
    })
    .catch(error => {
      console.error('Ошибка:', error);
      alert('Произошла ошибка при отправке данных');
    });
  });
</script>

