import Navbar from '@/components/landing/Navbar';
import Hero from '@/components/landing/Hero';
import HowItWorks from '@/components/landing/HowItWorks';
import FeaturedGuides from '@/components/landing/FeaturedGuides';
import Services from '@/components/landing/Services';
import Safety from '@/components/landing/Safety';
import Testimonials from '@/components/landing/Testimonials';
import GuideRecruitment from '@/components/landing/GuideRecruitment';
import Footer from '@/components/landing/Footer';

export default function Home() {
  return (
    <main>
      <Navbar />
      <Hero />
      <HowItWorks />
      <FeaturedGuides />
      <Services />
      <Safety />
      <Testimonials />
      <GuideRecruitment />
      <Footer />
    </main>
  );
}
