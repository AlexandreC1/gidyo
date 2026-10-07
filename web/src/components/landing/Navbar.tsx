'use client';

import { useState } from 'react';
import Link from 'next/link';

const navLinks = [
  { label: 'The approach', href: '#how-it-works' },
  { label: 'Perspectives', href: '#guides-container' },
  { label: 'Explore themes', href: '#services' },
  { label: 'For local guides', href: '#become-guide' }
];

export default function Navbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <header className="site-header">
      <nav className="section-container nav-layout" aria-label="Main navigation">
        <Link href="/" className="brand-lockup" aria-label="GIDYO home">
          <span className="brand-mark" aria-hidden="true">G</span>
          <span>GIDYO<span className="brand-period">.</span></span>
        </Link>

        <div className="desktop-nav">
          {navLinks.map((link) => (
            <Link key={link.href} href={link.href}>{link.label}</Link>
          ))}
        </div>

        <Link href="#how-it-works" className="nav-cta">Begin here <span aria-hidden="true">↗</span></Link>

        <button
          type="button"
          className="menu-toggle"
          onClick={() => setIsMenuOpen(!isMenuOpen)}
          aria-expanded={isMenuOpen}
          aria-controls="mobile-navigation"
          aria-label={isMenuOpen ? 'Close navigation menu' : 'Open navigation menu'}
        >
          <span /><span />
        </button>

        {isMenuOpen && (
          <div id="mobile-navigation" className="mobile-nav">
            {navLinks.map((link) => (
              <Link key={link.href} href={link.href} onClick={() => setIsMenuOpen(false)}>
                {link.label}<span aria-hidden="true">↗</span>
              </Link>
            ))}
          </div>
        )}
      </nav>
    </header>
  );
}
