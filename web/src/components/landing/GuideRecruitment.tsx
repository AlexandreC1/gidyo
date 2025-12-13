'use client';

import { useState } from 'react';

export default function GuideRecruitment() {
  const [tripsPerWeek, setTripsPerWeek] = useState(10);
  const averageTripPrice = 100;
  const guideCommission = 0.8; // 80%

  const weeklyEarnings = tripsPerWeek * averageTripPrice * guideCommission;
  const monthlyEarnings = weeklyEarnings * 4;
  const yearlyEarnings = monthlyEarnings * 12;

  const benefits = [
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      title: 'Flexible Schedule',
      description: 'Work when you want. Set your own availability and rates'
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      title: 'Fair Earnings',
      description: 'Keep 80% of every booking. Weekly payouts via Stripe or MonCash'
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
      ),
      title: 'Insurance Coverage',
      description: 'Comprehensive liability insurance included for all bookings'
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
        </svg>
      ),
      title: 'Free Training',
      description: 'Access to safety training, customer service workshops, and resources'
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
      ),
      title: 'Community Support',
      description: 'Join a network of 200+ verified guides across Haiti'
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      ),
      title: 'Marketing Tools',
      description: 'Professional profile, booking management, and promotional support'
    }
  ];

  return (
    <section id="become-guide" className="py-20 bg-white">
      <div className="section-container">
        {/* Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center px-4 py-2 bg-accent-golden/10 rounded-full text-accent-golden font-semibold mb-6">
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
            </svg>
            For Local Guides
          </div>

          <h2 className="text-4xl md:text-6xl font-bold text-primary-navy mb-6">
            Become a GIDYO Guide
          </h2>

          <p className="text-xl md:text-2xl text-gray-600 max-w-3xl mx-auto">
            Share your love for Haiti with the world and earn money on your own terms
          </p>
        </div>

        {/* Benefits Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
          {benefits.map((benefit, index) => (
            <div key={index} className="flex items-start space-x-4">
              <div className="flex-shrink-0 w-14 h-14 bg-gradient-to-br from-accent-teal/10 to-accent-golden/10 rounded-xl flex items-center justify-center text-accent-teal">
                {benefit.icon}
              </div>
              <div>
                <h3 className="font-bold text-lg text-primary-navy mb-2">{benefit.title}</h3>
                <p className="text-gray-600">{benefit.description}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Earnings Calculator */}
        <div className="bg-gradient-to-br from-accent-teal to-accent-teal/80 rounded-3xl p-8 md:p-12 text-white mb-12">
          <h3 className="text-3xl font-bold mb-6 text-center">Earnings Calculator</h3>

          <div className="max-w-2xl mx-auto">
            <div className="mb-8">
              <div className="flex items-center justify-between mb-4">
                <label className="text-lg font-semibold">Trips per week:</label>
                <span className="text-2xl font-bold">{tripsPerWeek}</span>
              </div>
              <input
                type="range"
                min="1"
                max="30"
                value={tripsPerWeek}
                onChange={(e) => setTripsPerWeek(parseInt(e.target.value))}
                className="w-full h-2 bg-white/20 rounded-lg appearance-none cursor-pointer slider"
              />
              <div className="flex justify-between text-sm text-white/70 mt-2">
                <span>1 trip</span>
                <span>30 trips</span>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 text-center">
                <div className="text-3xl font-bold mb-2">${weeklyEarnings.toFixed(0)}</div>
                <div className="text-white/70">Per Week</div>
              </div>
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 text-center">
                <div className="text-3xl font-bold mb-2">${monthlyEarnings.toFixed(0)}</div>
                <div className="text-white/70">Per Month</div>
              </div>
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 text-center">
                <div className="text-3xl font-bold mb-2">${yearlyEarnings.toFixed(0)}</div>
                <div className="text-white/70">Per Year</div>
              </div>
            </div>

            <p className="text-center text-white/70 mt-6 text-sm">
              Based on average trip price of ${averageTripPrice} and 80% guide commission
            </p>
          </div>
        </div>

        {/* CTA */}
        <div className="text-center">
          <button className="btn-secondary px-12 py-4 text-lg">
            Apply to Become a Guide
          </button>
          <p className="text-gray-600 mt-4">
            Average approval time: 3-5 business days
          </p>
        </div>

        {/* Requirements */}
        <div className="mt-16 bg-neutral-lightGray rounded-2xl p-8">
          <h3 className="text-2xl font-bold text-primary-navy mb-6 text-center">Requirements to Join</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-3xl mx-auto">
            <div className="flex items-center space-x-3">
              <svg className="w-6 h-6 text-accent-teal flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span>Valid Haitian government-issued ID</span>
            </div>
            <div className="flex items-center space-x-3">
              <svg className="w-6 h-6 text-accent-teal flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span>Vehicle with valid registration (for drivers)</span>
            </div>
            <div className="flex items-center space-x-3">
              <svg className="w-6 h-6 text-accent-teal flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span>Clean background check</span>
            </div>
            <div className="flex items-center space-x-3">
              <svg className="w-6 h-6 text-accent-teal flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span>Fluency in at least 2 languages</span>
            </div>
            <div className="flex items-center space-x-3">
              <svg className="w-6 h-6 text-accent-teal flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span>Smartphone with data plan</span>
            </div>
            <div className="flex items-center space-x-3">
              <svg className="w-6 h-6 text-accent-teal flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
              <span>Knowledge of local areas and attractions</span>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        .slider::-webkit-slider-thumb {
          appearance: none;
          width: 24px;
          height: 24px;
          background: white;
          border-radius: 50%;
          cursor: pointer;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        .slider::-moz-range-thumb {
          width: 24px;
          height: 24px;
          background: white;
          border-radius: 50%;
          cursor: pointer;
          border: none;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
      `}</style>
    </section>
  );
}
