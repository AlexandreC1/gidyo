const categories = [
  {
    number: '01',
    name: 'Stories & history',
    description: 'Look closer at the layers of memory and meaning in a place.',
    color: 'category-red'
  },
  {
    number: '02',
    name: 'Art & makers',
    description: 'Spend time with creative practices, ideas and the people behind them.',
    color: 'category-blue'
  },
  {
    number: '03',
    name: 'Food & markets',
    description: 'Find your way into local tastes, ingredients and daily exchange.',
    color: 'category-yellow'
  },
  {
    number: '04',
    name: 'Neighborhood life',
    description: 'See the everyday, shaped by someone who calls it home.',
    color: 'category-green'
  }
];

export default function Services() {
  return (
    <section id="services" className="categories-section">
      <div className="section-container">
        <div className="categories-intro">
          <p className="eyebrow"><span className="eyebrow-mark" /> Choose a thread</p>
          <h2>What are you<br /><em>curious about?</em></h2>
          <p>There’s no set route. These themes are an easy place to begin a conversation.</p>
        </div>
        <div className="category-list">
          {categories.map((category) => (
            <article className={`category-row ${category.color}`} key={category.number}>
              <span className="category-number">{category.number}</span>
              <h3>{category.name}</h3>
              <p>{category.description}</p>
              <span className="category-arrow" aria-hidden="true">↗</span>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
