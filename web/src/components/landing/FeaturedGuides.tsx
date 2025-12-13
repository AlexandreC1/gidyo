'use client';

import { useState } from 'react';

interface Guide {
  id: number;
  name: string;
  photo: string;
  rating: number;
  reviews: number;
  languages: string[];
  specialties: string[];
  startingPrice: number;
  location: string;
}

export default function FeaturedGuides() {
  const [scrollPosition, setScrollPosition] = useState(0);

  const guides: Guide[] = [
    {
      id: 1,
      name: 'Jean-Baptiste Laurent',
      photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      rating: 4.9,
      reviews: 127,
      languages: ['EN', 'FR', 'HT'],
      specialties: ['City Guide', 'Cultural Tours'],
      startingPrice: 75,
      location: 'Port-au-Prince'
    },
    {
      id: 2,
      name: 'Marie-Claire Joseph',
      photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
      rating: 5.0,
      reviews: 89,
      languages: ['EN', 'FR', 'HT'],
      specialties: ['Airport Pickup', 'Daily Driver'],
      startingPrice: 50,
      location: 'Pétion-Ville'
    },
    {
      id: 3,
      name: 'Pierre Alexandre',
      photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
      rating: 4.8,
      reviews: 156,
      languages: ['EN', 'FR', 'HT'],
      specialties: ['Security Escort', 'Fixer Services'],
      startingPrice: 200,
      location: 'Port-au-Prince'
    },
    {
      id: 4,
      name: 'Nadège Beauvoir',
      photo: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300',
      rating: 4.9,
      reviews: 94,
      languages: ['EN', 'FR', 'HT', 'ES'],
      specialties: ['Cultural Immersion', 'Art Tours'],
      startingPrice: 120,
      location: 'Jacmel'
    },
    {
      id: 5,
      name: 'Jacques Etienne',
      photo: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
      rating: 4.7,
      reviews: 73,
      languages: ['EN', 'FR', 'HT'],
      specialties: ['Daily Driver', 'Vehicle Rental'],
      startingPrice: 90,
      location: 'Cap-Haïtien'
    },
    {
      id: 6,
      name: 'Roseline Michel',
      photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300',
      rating: 5.0,
      reviews: 112,
      languages: ['EN', 'FR', 'HT'],
      specialties: ['City Guide', 'Food Tours'],
      startingPrice: 80,
      location: 'Port-au-Prince'
    }
  ];

  const scroll = (direction: 'left' | 'right') => {
    const container = document.getElementById('guides-container');
    if (container) {
      const scrollAmount = 400;
      const newPosition = direction === 'left'
        ? container.scrollLeft - scrollAmount
        : container.scrollLeft + scrollAmount;

      container.scrollTo({ left: newPosition, behavior: 'smooth' });
      setScrollPosition(newPosition);
    }
  };

  return (
    <section className="py-20 bg-neutral-lightGray">
      <div className="section-container">
        <div className="flex items-center justify-between mb-12">
          <div>
            <h2 className="text-4xl md:text-5xl font-bold text-primary-navy mb-4">
              Featured Guides
            </h2>
            <p className="text-xl text-gray-600">
              Top-rated local experts ready to show you Haiti
            </p>
          </div>

          {/* Navigation Buttons */}
          <div className="hidden md:flex space-x-2">
            <button
              onClick={() => scroll('left')}
              className="p-3 rounded-full bg-white hover:bg-accent-teal hover:text-white transition-all shadow-md"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <button
              onClick={() => scroll('right')}
              className="p-3 rounded-full bg-white hover:bg-accent-teal hover:text-white transition-all shadow-md"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>

        {/* Guides Carousel */}
        <div
          id="guides-container"
          className="flex overflow-x-auto space-x-6 pb-4 scrollbar-hide snap-x snap-mandatory"
          style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
        >
          {guides.map((guide) => (
            <div
              key={guide.id}
              className="flex-shrink-0 w-80 bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-300 group snap-start"
            >
              {/* Guide Photo */}
              <div className="relative h-80 overflow-hidden">
                <img
                  src={guide.photo}
                  alt={guide.name}
                  className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />

                {/* View Profile Button (visible on hover) */}
                <div className="absolute inset-0 bg-accent-teal/0 group-hover:bg-accent-teal/20 transition-all duration-300 flex items-center justify-center">
                  <button className="opacity-0 group-hover:opacity-100 transform translate-y-4 group-hover:translate-y-0 transition-all duration-300 btn-primary">
                    View Profile
                  </button>
                </div>

                {/* Rating Badge */}
                <div className="absolute top-4 right-4 bg-white rounded-full px-3 py-1 flex items-center space-x-1">
                  <svg className="w-4 h-4 text-accent-golden" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                  <span className="font-semibold text-sm">{guide.rating}</span>
                  <span className="text-gray-500 text-sm">({guide.reviews})</span>
                </div>
              </div>

              {/* Guide Info */}
              <div className="p-6">
                <div className="flex items-center justify-between mb-2">
                  <h3 className="text-xl font-bold text-primary-navy">{guide.name}</h3>
                </div>

                <div className="flex items-center text-gray-600 text-sm mb-4">
                  <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  {guide.location}
                </div>

                {/* Languages */}
                <div className="flex flex-wrap gap-2 mb-4">
                  {guide.languages.map((lang) => (
                    <span key={lang} className="px-2 py-1 bg-accent-teal/10 text-accent-teal text-xs font-medium rounded">
                      {lang}
                    </span>
                  ))}
                </div>

                {/* Specialties */}
                <div className="flex flex-wrap gap-2 mb-4">
                  {guide.specialties.map((specialty) => (
                    <span key={specialty} className="text-sm text-gray-600">
                      • {specialty}
                    </span>
                  ))}
                </div>

                {/* Pricing */}
                <div className="pt-4 border-t border-neutral-lightGray">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-600">Starting at</span>
                    <div className="text-right">
                      <span className="text-2xl font-bold text-primary-navy">${guide.startingPrice}</span>
                      <span className="text-gray-600 text-sm">/day</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* View All Button */}
        <div className="text-center mt-12">
          <button className="btn-outline px-8 py-4">
            View All Guides
          </button>
        </div>
      </div>

      <style jsx>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
      `}</style>
    </section>
  );
}
