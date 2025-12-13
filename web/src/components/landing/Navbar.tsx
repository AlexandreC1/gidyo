'use client';

import { useState } from 'react';
import Link from 'next/link';

export default function Navbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [language, setLanguage] = useState('en');

  const languages = {
    en: { name: 'English', flag: '🇺🇸' },
    fr: { name: 'Français', flag: '🇫🇷' },
    ht: { name: 'Kreyòl', flag: '🇭🇹' }
  };

  const navLinks = {
    en: ['How It Works', 'Find Guides', 'Become a Guide', 'Safety'],
    fr: ['Comment ça marche', 'Trouver des guides', 'Devenir guide', 'Sécurité'],
    ht: ['Kijan li fonksyone', 'Jwenn gid', 'Vin yon gid', 'Sekirite']
  };

  const ctaText = {
    en: { download: 'Download App', becomeGuide: 'Become a Guide' },
    fr: { download: 'Télécharger', becomeGuide: 'Devenir guide' },
    ht: { download: 'Telechaje App', becomeGuide: 'Vin yon gid' }
  };

  return (
    <nav className="fixed top-0 left-0 right-0 bg-white shadow-md z-50">
      <div className="section-container">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2">
            <div className="w-10 h-10 bg-gradient-to-br from-accent-teal to-accent-golden rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-xl">G</span>
            </div>
            <span className="text-2xl font-bold text-primary-navy">GIDYO</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navLinks[language as keyof typeof navLinks].map((link, idx) => (
              <Link
                key={idx}
                href={`#${link.toLowerCase().replace(/\s+/g, '-')}`}
                className="text-primary-navy hover:text-accent-teal transition-colors duration-200 font-medium"
              >
                {link}
              </Link>
            ))}
          </div>

          {/* CTA Buttons & Language Switcher */}
          <div className="hidden md:flex items-center space-x-4">
            {/* Language Switcher */}
            <div className="relative group">
              <button className="flex items-center space-x-1 px-3 py-2 rounded-lg hover:bg-neutral-lightGray transition-colors">
                <span>{languages[language as keyof typeof languages].flag}</span>
                <span className="text-sm font-medium">{language.toUpperCase()}</span>
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div className="absolute right-0 mt-2 w-40 bg-white rounded-lg shadow-lg py-2 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200">
                {Object.entries(languages).map(([code, { name, flag }]) => (
                  <button
                    key={code}
                    onClick={() => setLanguage(code)}
                    className="w-full px-4 py-2 text-left hover:bg-neutral-lightGray flex items-center space-x-2"
                  >
                    <span>{flag}</span>
                    <span className="text-sm">{name}</span>
                  </button>
                ))}
              </div>
            </div>

            <Link href="#download" className="btn-outline text-sm py-2 px-4">
              {ctaText[language as keyof typeof ctaText].download}
            </Link>
            <Link href="#become-guide" className="btn-primary text-sm py-2 px-4">
              {ctaText[language as keyof typeof ctaText].becomeGuide}
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="md:hidden p-2 rounded-lg hover:bg-neutral-lightGray"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              {isMenuOpen ? (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              )}
            </svg>
          </button>
        </div>

        {/* Mobile Menu */}
        {isMenuOpen && (
          <div className="md:hidden py-4 border-t border-neutral-lightGray">
            <div className="flex flex-col space-y-4">
              {navLinks[language as keyof typeof navLinks].map((link, idx) => (
                <Link
                  key={idx}
                  href={`#${link.toLowerCase().replace(/\s+/g, '-')}`}
                  className="text-primary-navy hover:text-accent-teal transition-colors py-2"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {link}
                </Link>
              ))}
              <div className="flex flex-col space-y-2 pt-4 border-t border-neutral-lightGray">
                <Link href="#download" className="btn-outline text-center">
                  {ctaText[language as keyof typeof ctaText].download}
                </Link>
                <Link href="#become-guide" className="btn-primary text-center">
                  {ctaText[language as keyof typeof ctaText].becomeGuide}
                </Link>
              </div>
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}
