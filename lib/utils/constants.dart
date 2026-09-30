// const String API_BASE_URL = "http://10.0.2.2:5114/api";
// const String API_BASE_URL = "http://10.0.10.43:5114/api";
// const String API_BASE_URL = "http://10.0.10.51:5114/api";
// const String API_BASE_URL = "http://10.0.5.38:3000/api";

// const String API_BASE_URL = "http://10.0.5.34:8001/api";
// prod
const String API_BASE_URL = "https://careers.meconlimited.co.in/m_app/api";
const String API_KEY = "V_z_4R3sda0Q3v6b2uhpsod8SzvUBn99SZhBM0t2p-o";

/// Headers required by the Mecon API. Merge extra headers (auth, content type) on top.
Map<String, String> apiHeaders([Map<String, String>? extra]) => {
      'x-api-key': API_KEY,
      if (extra != null) ...extra,
    };

// dev
// const String API_BASE_URL = "http://10.0.10.58:8001/api";

