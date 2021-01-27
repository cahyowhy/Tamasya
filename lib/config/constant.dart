class Constant {
  static const int REQUEST_TIMEOUT_S = 60;

  static const String FULL_DATE_FORMATED = "dd-MM-yy HH:mm";

  static const String HOUR_FORMATED = "HH:mm";

  static const String DATE_DAY = "EEEE";

  static const String SIMPLE_DATE_FORMATED = "dd MMM yyyy";

  static const String SIMPLEST_DATE_FORMATED = "d MMM yy";

  static const String SIMPLEST_DATE_FORMATED_2 = "d/MM/yyyy";

  static const String DATE_FORMAT_SEARCH = "yyyy-MM-dd";

  static const String STORAGE_USER_KEY = "USER";

  static const String STORAGE_FILTER_HOTEL_KEY = "FILTER_HOTEL";
  
  static const String STORAGE_FILTER_FLIGHT_KEY = "FILTER_FLIGHT";
  
  static const String STORAGE_FILTER_TOUR_KEY = "FILTER_TOUR";
  
  static const String STORAGE_FILTER_CURRENCY_KEY = "CURRENCY_KEY";

  static const int DEFAULT_MAP_ZOOM = 20;

  static const int MAX_LIMIT = 100;

  static const int PAGING_LIMIT = 20;

  static const int MAX_RADIUS_MAP = 300;
  
  static const int DEFAULT_RADIUS_MAP = 30;

  static const int MAX_PRICE_IN_EUR = 1000;

  static const String DEFAULT_CUR = "EUR";

  static const int MAX_EXPIRED_CACHE_HOUR = 6;
  
  static const int MAX_EXPIRED_CACHE_CURRENCY_DAY = 5;
  
  static const List<String> VIEW_BYS = [
    "DATE",
    "DESTINATION",
    "DURATION",
    "WEEK",
    "COUNTRY"
  ];

  static const List<String> TRAVEL_CLASS = [
    "ECONOMY",
    "PREMIUM_ECONOMY",
    "BUSINESS",
    "FIRST"
  ];

  static const List<String> HOTEL_AMENITIES = [
    "WIFI",
    "FITNESS_CENTER",
    "SWIMMING_POOL",
    "AIRPORT_SHUTTLE",
    "RESTAURANT",
    "PARKING",
    "SPA",
    "AIR_CONDITIONING",
    "PETS_ALLOWED",
    "BUSINESS_CENTER",
    "DISABLED_FACILITIES",
    "MEETING_ROOMS",
    "NO_KID_ALLOWED",
    "TENNIS",
    "GOLF",
    "KITCHEN",
    "ANIMAL_WATCHING",
    "BABY-SITTING",
    "BEACH",
    "CASINO",
    "JACUZZI",
    "SAUNA",
    "SOLARIUM",
    "MASSAGE",
    "VALET_PARKING",
    "BAR",
    "KIDS_WELCOME",
    "NO_PORN_FILMS",
    "MINIBAR",
    "TELEVISION",
    "WI-FI_IN_ROOM",
    "ROOM_SERVICE",
    "GUARDED_PARKG",
    "SERV_SPEC_MENU"
  ];

  static const int HTTP_UNAUTHORIZE = 401;

  static const int MAX_DATA_USE_COMPUTE = 100;

  static const Map<String, String> HOTEL_BOARD_TYPE = {
    "ROOM_ONLY": "Room Only",
    "BREAKFAST": "Bed & Breakfast",
    "HALF_BOARD": "Diner & Bed & Breakfast (only for Aggregators)",
    "FULL_BOARD": "Full Board (only for Aggregators)",
    "ALL_INCLUSIVE": "All Inclusive (only for Aggregators)"
  };

  static const Map<String, String> CURRENCY_SYMBOL = {
  "AED": "د.إ",
  "AFN": "؋",
  "ALL": "L",
  "AMD": "֏",
  "ANG": "ƒ",
  "AOA": "Kz",
  "ARS": r"$",
  "AUD": r"$",
  "AWG": "ƒ",
  "AZN": "₼",
  "BAM": "KM",
  "BBD": r"$",
  "BDT": "৳",
  "BGN": "лв",
  "BHD": ".د.ب",
  "BIF": "FBu",
  "BMD": r"$",
  "BND": r"$",
  "BOB": r"$b",
  "BRL": r"R$",
  "BSD": r"$",
  "BTC": "฿",
  "BTN": "Nu.",
  "BWP": "P",
  "BYR": "Br",
  "BYN": "Br",
  "BZD": r"BZ$",
  "CAD": r"$",
  "CDF": "FC",
  "CHF": "CHF",
  "CLP": r"$",
  "CNY": "¥",
  "COP": r"$",
  "CRC": "₡",
  "CUC": r"$",
  "CUP": "₱",
  "CVE": r"$",
  "CZK": "Kč",
  "DJF": "Fdj",
  "DKK": "kr",
  "DOP": r"RD$",
  "DZD": "دج",
  "EEK": "kr",
  "EGP": "£",
  "ERN": "Nfk",
  "ETB": "Br",
  "ETH": "Ξ",
  "EUR": "€",
  "FJD": r"$",
  "FKP": "£",
  "GBP": "£",
  "GEL": "₾",
  "GGP": "£",
  "GHC": "₵",
  "GHS": "GH₵",
  "GIP": "£",
  "GMD": "D",
  "GNF": "FG",
  "GTQ": "Q",
  "GYD": r"$",
  "HKD": r"$",
  "HNL": "L",
  "HRK": "kn",
  "HTG": "G",
  "HUF": "Ft",
  "IDR": "Rp",
  "ILS": "₪",
  "IMP": "£",
  "INR": "₹",
  "IQD": "ع.د",
  "IRR": "﷼",
  "ISK": "kr",
  "JEP": "£",
  "JMD": r"J$",
  "JOD": "JD",
  "JPY": "¥",
  "KES": "KSh",
  "KGS": "лв",
  "KHR": "៛",
  "KMF": "CF",
  "KPW": "₩",
  "KRW": "₩",
  "KWD": "KD",
  "KYD": r"$",
  "KZT": "лв",
  "LAK": "₭",
  "LBP": "£",
  "LKR": "₨",
  "LRD": r"$",
  "LSL": "M",
  "LTC": "Ł",
  "LTL": "Lt",
  "LVL": "Ls",
  "LYD": "LD",
  "MAD": "MAD",
  "MDL": "lei",
  "MGA": "Ar",
  "MKD": "ден",
  "MMK": "K",
  "MNT": "₮",
  "MOP": r"MOP$",
  "MRO": "UM",
  "MRU": "UM",
  "MUR": "₨",
  "MVR": "Rf",
  "MWK": "MK",
  "MXN": r"$",
  "MYR": "RM",
  "MZN": "MT",
  "NAD": r"$",
  "NGN": "₦",
  "NIO": r"C$",
  "NOK": "kr",
  "NPR": "₨",
  "NZD": r"$",
  "OMR": "﷼",
  "PAB": "B/.",
  "PEN": "S/.",
  "PGK": "K",
  "PHP": "₱",
  "PKR": "₨",
  "PLN": "zł",
  "PYG": "Gs",
  "QAR": "﷼",
  "RMB": "￥",
  "RON": "lei",
  "RSD": "Дин.",
  "RUB": "₽",
  "RWF": "R₣",
  "SAR": "﷼",
  "SBD": r"$",
  "SCR": "₨",
  "SDG": "ج.س.",
  "SEK": "kr",
  "SGD": r"$",
  "SHP": "£",
  "SLL": "Le",
  "SOS": "S",
  "SRD": r"$",
  "SSP": "£",
  "STD": "Db",
  "STN": "Db",
  "SVC": r"$",
  "SYP": "£",
  "SZL": "E",
  "THB": "฿",
  "TJS": "SM",
  "TMT": "T",
  "TND": "د.ت",
  "TOP": r"T$",
  "TRL": "₤",
  "TRY": "₺",
  "TTD": r"TT$",
  "TVD": r"$",
  "TWD": r"NT$",
  "TZS": "TSh",
  "UAH": "₴",
  "UGX": "USh",
  "USD": r"$",
  "UYU": r"$U",
  "UZS": "лв",
  "VEF": "Bs",
  "VND": "₫",
  "VUV": "VT",
  "WST": r"WS$",
  "XAF": "FCFA",
  "XBT": "Ƀ",
  "XCD": r"$",
  "XOF": "CFA",
  "XPF": "₣",
  "YER": "﷼",
  "ZAR": "R",
  "ZWD": r"Z$"
};
}
