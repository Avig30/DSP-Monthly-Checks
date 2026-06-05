import type { Config } from 'tailwindcss'
const config: Config = {
  content: ['./pages/**/*.{js,ts,jsx,tsx,mdx}','./components/**/*.{js,ts,jsx,tsx,mdx}','./app/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      fontFamily: { sans: ['var(--font-inter)','system-ui','sans-serif'] },
      colors: {
        primary: { DEFAULT: '#0D9488', dark: '#0f766e', light: '#ccfbf1' },
        navy: { DEFAULT: '#1E3A5F', light: '#2d5a8e' },
      },
    },
  },
  plugins: [],
}
export default config
