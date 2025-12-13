export default function Services() {
  const services = [
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
        </svg>
      ),
      name: 'Airport Pickup',
      description: 'Safe and reliable airport transfer service to your destination',
      startingPrice: 50
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
        </svg>
      ),
      name: 'Daily Driver',
      description: 'Professional driver for the entire day at your disposal',
      startingPrice: 100
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
        </svg>
      ),
      name: 'City Guide',
      description: 'Explore the city with a knowledgeable local expert',
      startingPrice: 75
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        </svg>
      ),
      name: 'Cultural Immersion',
      description: 'Deep dive into Haitian culture, traditions, and local life',
      startingPrice: 150
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
      ),
      name: 'Security Escort',
      description: 'Professional security escort for safe travel throughout Haiti',
      startingPrice: 200
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
        </svg>
      ),
      name: 'Fixer Services',
      description: 'Logistics and coordination for journalists and filmmakers',
      startingPrice: 200
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
        </svg>
      ),
      name: 'Vehicle Rental',
      description: 'Rent a well-maintained vehicle with or without a driver',
      startingPrice: 80
    },
    {
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      ),
      name: 'Multi-day Package',
      description: 'Comprehensive tour package with accommodation and meals',
      startingPrice: 1000
    }
  ];

  return (
    <section id="services" className="py-20 bg-white">
      <div className="section-container">
        <h2 className="text-4xl md:text-5xl font-bold text-primary-navy text-center mb-4">
          Our Services
        </h2>
        <p className="text-xl text-gray-600 text-center mb-16 max-w-2xl mx-auto">
          From airport pickups to multi-day cultural tours, we have you covered
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {services.map((service, index) => (
            <div
              key={index}
              className="bg-white border-2 border-neutral-lightGray rounded-2xl p-6 hover:border-accent-teal hover:shadow-xl hover:-translate-y-2 transition-all duration-300 cursor-pointer group"
            >
              {/* Icon */}
              <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-accent-teal/10 to-accent-golden/10 rounded-xl text-accent-teal group-hover:scale-110 transition-transform duration-300 mb-4">
                {service.icon}
              </div>

              {/* Name */}
              <h3 className="text-xl font-bold text-primary-navy mb-2">{service.name}</h3>

              {/* Description */}
              <p className="text-gray-600 text-sm mb-4 line-clamp-2">{service.description}</p>

              {/* Price */}
              <div className="flex items-center justify-between pt-4 border-t border-neutral-lightGray">
                <span className="text-gray-600 text-sm">From</span>
                <span className="text-2xl font-bold text-accent-teal">${service.startingPrice}</span>
              </div>
            </div>
          ))}
        </div>

        <div className="text-center mt-12">
          <button className="btn-primary px-8 py-4">
            Explore All Services
          </button>
        </div>
      </div>
    </section>
  );
}
