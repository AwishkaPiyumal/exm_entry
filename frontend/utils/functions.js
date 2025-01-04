export function parseString(input) {
  const regex = /^(\d{4})([A-Za-z()]+)(\d)(\d)$/;
  const match = input.match(regex);

  if (match) {
    const academic_year = match[1];
    const degree_name_short = match[2];
    const level = match[3];
    const sem_no = match[4];

    return {
      academic_year,
      degree_name_short,
      level,
      sem_no,
      batch_code: input,
    };
  } else {
    throw new Error("Invalid format");
  }
}

export const numberToOrdinalWord = (numStr) => {
  const ordinalWords = [
    "zeroth",
    "first",
    "second",
    "third",
    "fourth",
    "fifth",
    "sixth",
    "seventh",
    "eighth",
    "ninth",
    "tenth",
    "eleventh",
    "twelfth",
    "thirteenth",
    "fourteenth",
    "fifteenth",
    "sixteenth",
    "seventeenth",
    "eighteenth",
    "nineteenth",
  ];

  const tensWords = [
    "",
    "",
    "twentieth",
    "thirtieth",
    "fortieth",
    "fiftieth",
    "sixtieth",
    "seventieth",
    "eightieth",
    "ninetieth",
  ];

  const num = parseInt(numStr, 10);

  if (isNaN(num) || num < 0) {
    return "Invalid input"; // Handle non-numeric or negative inputs
  }

  if (num < 20) {
    return ordinalWords[num];
  }

  const tens = Math.floor(num / 10);
  const ones = num % 10;

  if (ones === 0) {
    return tensWords[tens];
  }

  return tensWords[tens].replace("ieth", "y-") + ordinalWords[ones];
};

export function titleCase(str) {
  const excludedWords = [
    "and",
    "or",
    "but",
    "nor",
    "the",
    "a",
    "an",
    "in",
    "on",
    "at",
    "to",
    "by",
    "for",
    "with",
    "of",
    "from",
  ];
  return str
    .toLowerCase()
    .split(" ")
    .map((word, index) => {
      if (index === 0 || !excludedWords.includes(word)) {
        return word.charAt(0).toUpperCase() + word.slice(1);
      }
      return word;
    })
    .join(" ");
}

export const convertUTCToLocal = (utcDateStr) => {
  // Step 1: Parse the UTC date
  const date = new Date(utcDateStr);

  // Step 2: Convert to the desired time zone and format
  const options = {
    timeZone: "Asia/Colombo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23", // Use 24-hour format
  };

  // Adjust time and format to local string
  const localDateStr = date.toLocaleString("en-GB", options); // e.g., "09/12/2024, 06:50"

  // Step 3: Reformat the string to "yyyy-MM-ddThh:mm"
  const [datePart, timePart] = localDateStr.split(", ");
  return datePart.split("/").reverse().join("-") + "T" + timePart;
};

export function getModifiedDate(date) {
  const day = String(date.getDate()).padStart(2, "0");
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const year = date.getFullYear();

  return `${day}.${month}.${year}`;
}
