import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        primary: {
          navy: "#1E3A5F",
        },
        accent: {
          teal: "#0D9488",
          golden: "#D97706",
        },
        neutral: {
          white: "#FFFFFF",
          lightGray: "#F3F4F6",
        },
      },
    },
  },
  plugins: [],
};
export default config;
