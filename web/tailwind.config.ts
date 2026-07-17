import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        tiffany: "#0ABAB5",
        "tiffany-light": "#E6F9F8",
        "tiffany-mid": "rgba(10,186,181,0.15)",
        "app-bg": "#F8F9FA",
        "app-text": "#1A1A1A",
        "app-sub": "#6B7280",
        "card-border": "#E5E7EB",
        "app-gray": "#9CA3AF",
      },
      fontFamily: {
        sans: [
          "-apple-system",
          "BlinkMacSystemFont",
          '"Hiragino Sans"',
          '"Noto Sans JP"',
          "sans-serif",
        ],
      },
    },
  },
  plugins: [],
};
export default config;
