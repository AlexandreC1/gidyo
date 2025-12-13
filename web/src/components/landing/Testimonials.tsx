'use client';

import { useState, useEffect } from 'react';

interface Testimonial {
  id: number;
  quote: string;
  name: string;
  country: string;
  flag: string;
  rating: number;
  photo: string;
}

export default function Testimonials() {
  const [currentIndex, setCurrentIndex] = useState(0);

  const testimonials: Testimonial[] = [
    {
      id: 1,
      quote: "Jean-Baptiste was phenomenal! He showed us parts of Port-au-Prince we'd never have found on our own. His knowledge of Haitian history and culture made the experience unforgettable.",
      name: "Sarah Mitchell",
      country: "United States",
      flag: "🇺🇸",
      rating: 5,
      photo: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100"
    },
    {
      id: 2,
      quote: "As a solo female traveler, I was nervous about visiting Haiti. Marie-Claire made me feel completely safe and welcomed. She's now a friend, not just a guide!",
      name: "Sophie Dubois",
      country: "France",
      flag: "🇫🇷",
      rating: 5,
      photo: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100"
    },
    {
      id: 3,
      quote: "Pierre helped us film our documentary in Cap-Haïtien. His connections and local knowledge were invaluable. Professional, reliable, and genuinely passionate about showcasing Haiti.",
      name: "Marcus Johnson",
      country: "Canada",
      flag: "🇨🇦",
      rating: 5,
      photo: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100"
    },
    {
      id: 4,
      quote: "Nadège's cultural tour in Jacmel was the highlight of our trip. The artisan workshops, the local cuisine, the music - everything was authentic and beautifully curated.",
      name: "Emma Rodriguez",
      country: "Spain",
      flag: "🇪🇸",
      rating: 5,
      photo: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100"
    },
    {
      id: 5,
      quote: "I've used GIDYO for three business trips to Haiti. The consistency and reliability are unmatched. Highly recommend for anyone visiting Port-au-Prince.",
      name: "David Chen",
      country: "Singapore",
      flag: "🇸🇬",
      rating: 5,
      photo: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100"
    }
  ];

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % testimonials.length);
    }, 5000);

    return () => clearInterval(timer);
  }, [testimonials.length]);

  const goToSlide = (index: number) => {
    setCurrentIndex(index);
  };

  const goToPrevious = () => {
    setCurrentIndex((prevIndex) =>
      prevIndex === 0 ? testimonials.length - 1 : prevIndex - 1
    );
  };

  const goToNext = () => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % testimonials.length);
  };

  return (
    <section className="py-20 bg-gradient-to-br from-primary-navy to-primary-navy/90 text-white relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: 'url("data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
        }} />
      </div>

      <div className="section-container relative z-10">
        <h2 className="text-4xl md:text-5xl font-bold text-center mb-4">
          What Travelers Say
        </h2>
        <p className="text-xl text-white/80 text-center mb-16 max-w-2xl mx-auto">
          Real experiences from travelers who explored Haiti with GIDYO guides
        </p>

        {/* Testimonial Carousel */}
        <div className="max-w-4xl mx-auto">
          <div className="bg-white/10 backdrop-blur-md rounded-3xl p-8 md:p-12 shadow-2xl">
            {/* Stars */}
            <div className="flex justify-center mb-6">
              {[...Array(testimonials[currentIndex].rating)].map((_, i) => (
                <svg key={i} className="w-6 h-6 text-accent-golden" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              ))}
            </div>

            {/* Quote */}
            <blockquote className="text-xl md:text-2xl text-center mb-8 leading-relaxed">
              "{testimonials[currentIndex].quote}"
            </blockquote>

            {/* Author */}
            <div className="flex items-center justify-center space-x-4">
              <img
                src={testimonials[currentIndex].photo}
                alt={testimonials[currentIndex].name}
                className="w-16 h-16 rounded-full object-cover border-4 border-accent-golden"
              />
              <div className="text-left">
                <div className="font-bold text-lg">{testimonials[currentIndex].name}</div>
                <div className="text-white/70 flex items-center">
                  <span className="mr-2">{testimonials[currentIndex].flag}</span>
                  {testimonials[currentIndex].country}
                </div>
              </div>
            </div>
          </div>

          {/* Navigation */}
          <div className="flex items-center justify-center mt-8 space-x-4">
            <button
              onClick={goToPrevious}
              className="p-3 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>

            {/* Dots */}
            <div className="flex space-x-2">
              {testimonials.map((_, index) => (
                <button
                  key={index}
                  onClick={() => goToSlide(index)}
                  className={`w-2 h-2 rounded-full transition-all duration-300 ${
                    index === currentIndex
                      ? 'w-8 bg-accent-golden'
                      : 'bg-white/30 hover:bg-white/50'
                  }`}
                />
              ))}
            </div>

            <button
              onClick={goToNext}
              className="p-3 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-16 max-w-3xl mx-auto">
          <div className="text-center">
            <div className="text-4xl font-bold text-accent-golden mb-2">4.9/5</div>
            <div className="text-white/70">Average Rating</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-bold text-accent-golden mb-2">5,000+</div>
            <div className="text-white/70">Happy Travelers</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-bold text-accent-golden mb-2">98%</div>
            <div className="text-white/70">Would Recommend</div>
          </div>
        </div>
      </div>
    </section>
  );
}
