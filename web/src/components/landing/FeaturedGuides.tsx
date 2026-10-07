import Link from 'next/link';

const perspectives = [
  {
    number: '01',
    title: 'Stories & history',
    note: 'A place is more than the dates in a guidebook.',
    treatment: 'perspective-stories',
    shape: 'A'
  },
  {
    number: '02',
    title: 'Art & makers',
    note: 'Make room for the hands and ideas shaping what comes next.',
    treatment: 'perspective-makers',
    shape: 'B'
  },
  {
    number: '03',
    title: 'Food & markets',
    note: 'Follow the conversations that happen around a table.',
    treatment: 'perspective-food',
    shape: 'C'
  }
];

export default function FeaturedGuides() {
  return (
    <section id="guides-container" className="perspectives-section">
      <div className="section-container">
        <div className="section-heading heading-split">
          <div>
            <p className="eyebrow"><span className="eyebrow-mark" /> Perspectives, not profiles</p>
            <h2>Every place has<br /><em>more than one story.</em></h2>
          </div>
          <p className="heading-aside">
            Start with a point of view. We’ll help shape a visit around what you’re curious about and the people who know it best.
          </p>
        </div>

        <div className="perspective-grid">
          {perspectives.map((perspective) => (
            <article className={`perspective-card ${perspective.treatment}`} key={perspective.number}>
              <div className="perspective-art" aria-hidden="true">
                <span className="perspective-glyph">{perspective.shape}</span>
                <span className="perspective-serial">{perspective.number} / OPEN CANVAS</span>
                <span className="perspective-orbit" />
              </div>
              <div className="perspective-meta">
                <span>{perspective.number}</span>
                <span>ILLUSTRATIVE THEME</span>
              </div>
              <h3>{perspective.title}</h3>
              <p>{perspective.note}</p>
            </article>
          ))}
        </div>

        <p className="editorial-note">
          These are starting points, not bookable listings. Each traveler request is reviewed by a person; local perspectives are shared with care.
        </p>
        <Link href="#how-it-works" className="text-link">
          See how requests are considered <span aria-hidden="true">↗</span>
        </Link>
      </div>
    </section>
  );
}
