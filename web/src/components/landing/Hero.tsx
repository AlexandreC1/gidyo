import Link from 'next/link';

export default function Hero() {
  return (
    <section className="hero-section">
      <div className="section-container hero-layout">
        <div className="hero-copy">
          <p className="eyebrow"><span className="eyebrow-mark" /> An invitation to see differently</p>
          <h1>Haiti,<br />through <em>local eyes.</em></h1>
          <p className="hero-intro">
            Go beyond the itinerary. Meet the stories, makers, flavors and everyday rhythms that make a place feel like itself.
          </p>
          <div className="hero-actions">
            <Link href="#how-it-works" className="button-ink">
              How it begins <span aria-hidden="true">↗</span>
            </Link>
            <span className="hero-note">A thoughtful, human-reviewed way to explore.</span>
          </div>
          <div className="hero-index" aria-hidden="true">
            <span>01</span><span className="index-line" /><span>Haiti, in its own words</span>
          </div>
        </div>

        <div className="hero-artwork" role="img" aria-label="Original abstract editorial artwork placeholder">
          <div className="artwork-caption">
            <span>FIELD NOTES / 001</span>
            <span>HAITI</span>
          </div>
          <div className="artwork-shape artwork-shape-one" />
          <div className="artwork-shape artwork-shape-two" />
          <div className="artwork-shape artwork-shape-three" />
          <span className="artwork-letter" aria-hidden="true">G</span>
          <p className="artwork-credit">An open canvas for locally authored work.</p>
          <span className="artwork-side-note" aria-hidden="true">PLACE / PEOPLE / PERSPECTIVE</span>
        </div>
      </div>
      <div className="hero-baseline section-container">
        <span>Not a checklist. A connection.</span>
        <span>Across Haiti / one perspective at a time</span>
      </div>
    </section>
  );
}
