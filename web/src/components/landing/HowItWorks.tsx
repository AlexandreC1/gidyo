export default function HowItWorks() {
  const steps = [
    {
      number: '01',
      title: 'Tell us what draws you in',
      description: 'Share the place, questions or interests you’re carrying into your trip.'
    },
    {
      number: '02',
      title: 'A person reads your request',
      description: 'Every request is reviewed by the team. This is a conversation, not instant booking.'
    },
    {
      number: '03',
      title: 'Explore what could fit',
      description: 'We’ll help you think through a thoughtful local perspective for your visit.'
    }
  ];

  return (
    <section id="how-it-works" className="process-section">
      <div className="section-container">
        <div className="process-topline">
          <p className="eyebrow"><span className="eyebrow-mark" /> A more considered beginning</p>
          <span className="process-aside">01 — 03 / THE REQUEST</span>
        </div>
        <div className="process-heading">
          <h2>Start with a question.<br /><em>Meet it with a person.</em></h2>
          <p>GIDYO is building a more thoughtful way to connect visitors with local perspective in Haiti.</p>
        </div>
        <div className="process-steps">
          {steps.map((step) => (
            <article className="process-step" key={step.number}>
              <span className="process-number">{step.number}</span>
              <h3>{step.title}</h3>
              <p>{step.description}</p>
            </article>
          ))}
        </div>
        <p className="process-footnote">Traveler requests aren’t submitted on this page yet. We’ll share the request path when it’s ready.</p>
      </div>
    </section>
  );
}
