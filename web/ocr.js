async function readTextFromImage(base64Image) {
  const result = await Tesseract.recognize(
    base64Image,
    'eng'
  );

  return result.data.text; // IMPORTANT
}