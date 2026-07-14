---
title: JavaScript code style good practices
date: 2024-02-02 11:00:00
categories: [Fondement]
tags: [javascript, notions, noyau, codestyle]     # TAG names should always be lowercase
author: GoXLd
pin: false
published: true
language: en
translation_key: javascript-code-style
permalink: /posts/en/javascript-code-style/
---

# Good practices for indentation in JavaScript code

Indentation is an essential component of code style in JavaScript. It improves code readability, eases maintenance and fosters effective collaboration within a development team. In this article we will explore a few good practices regarding indentation in JavaScript code.

## 1. Use spaces rather than tabs

Although JavaScript allows tabs for indentation, using spaces is recommended. It guarantees consistency across the whole codebase, regardless of the editor used. The common standard is two spaces per indentation level.

```javascript
// Bad
function exemple() {
  var x = 1;
}

// Good
function exemple() {
  var x = 1;
}
```

## 2. Use braces even for single-line blocks

Although JavaScript allows omitting braces for single-line blocks, it is better to always include them. It prevents potential mistakes and improves code readability.

```javascript
// Bad
if (condition)
  console.log("Une seule ligne");

// Good
if (condition) {
  console.log("Une seule ligne");
}

```

## 3. Align indentation levels properly

Make sure code blocks at different indentation levels are properly aligned. It improves code clarity and makes the program structure easier to understand.

```javascript
// Bad
// Bad
function exemple() {
  var x = 1;
    if (x === 1) {
  console.log("Alignement incorrect");
  }
}

// Good
function exemple() {
  var x = 1;
  if (x === 1) {
    console.log("Alignement correct");
  }
}

```

In conclusion, proper indentation is essential to keep JavaScript code readable and consistent. By following these good practices, you will help improve the quality of your code and ease collaboration within your development team.
