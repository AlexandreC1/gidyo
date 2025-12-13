-- GIDYO Seed Data
-- Service types and service areas for the platform

-- =====================================================
-- SERVICE TYPES
-- =====================================================

INSERT INTO service_types (name_en, name_fr, name_ht, description_en, description_fr, description_ht, base_price, price_unit, icon) VALUES
(
    'Airport Pickup',
    'Prise en charge à l''aéroport',
    'Al chèche nan ayewopò',
    'Safe and reliable airport transfer service. Your guide will meet you at the airport and transport you to your destination.',
    'Service de transfert aéroport sûr et fiable. Votre guide vous attendra à l''aéroport et vous conduira à votre destination.',
    'Sèvis transpò nan ayewopò ki an sekirite. Gid ou a ap rankontre ou nan ayewopò epi mennen ou nan destinasyon ou.',
    50.00,
    'per_person',
    'plane'
),
(
    'Daily Driver',
    'Chauffeur à la journée',
    'Chofè pou tout jounen',
    'Professional driver for the entire day. Go where you want, when you want, with a knowledgeable local driver.',
    'Chauffeur professionnel pour toute la journée. Allez où vous voulez, quand vous voulez, avec un chauffeur local expérimenté.',
    'Chofè pwofesyonèl pou tout jounen. Ale kote ou vle, lè ou vle, ak yon chofè lokal ki gen eksperyans.',
    100.00,
    'per_day',
    'car'
),
(
    'City Guide',
    'Guide de ville',
    'Gid vil',
    'Explore the city with a local expert. Discover hidden gems, local cuisine, and authentic culture.',
    'Explorez la ville avec un expert local. Découvrez des trésors cachés, une cuisine locale et une culture authentique.',
    'Eksplore vil la ak yon ekspè lokal. Dekouvri kote ki kache, manje lokal, ak kilti otantik.',
    75.00,
    'per_day',
    'map'
),
(
    'Cultural Immersion',
    'Immersion culturelle',
    'Enpèzyon kiltirèl',
    'Deep dive into Haitian culture, traditions, and daily life. Visit local markets, artisan workshops, and community events.',
    'Plongez dans la culture, les traditions et la vie quotidienne haïtiennes. Visitez les marchés locaux, les ateliers d''artisans et les événements communautaires.',
    'Enplike tèt ou nan kilti, tradisyon, ak lavi chak jou Ayisyen. Vizite mache lokal, atèlye atizan, ak evenman kominotè.',
    150.00,
    'per_day',
    'heart'
),
(
    'Security Escort',
    'Escorte de sécurité',
    'Eskòt sekirite',
    'Professional security escort for safe travel throughout Haiti. Ideal for business travelers and high-profile visitors.',
    'Escorte de sécurité professionnelle pour voyager en toute sécurité en Haïti. Idéal pour les voyageurs d''affaires et les visiteurs de haut niveau.',
    'Eskòt sekirite pwofesyonèl pou vwayaje an sekirite nan tout peyi Ayiti. Bon pou moun ki nan biznis ak vizitè enpòtan.',
    200.00,
    'per_day',
    'shield'
),
(
    'Fixer Services',
    'Services de coordination',
    'Sèvis kòdinasyon',
    'Logistics and coordination services for journalists, filmmakers, and researchers. Includes local contacts, permits, and on-ground support.',
    'Services de logistique et de coordination pour journalistes, cinéastes et chercheurs. Comprend les contacts locaux, les permis et le soutien sur le terrain.',
    'Sèvis lojistik ak kòdinasyon pou jounalis, sineas, ak chèchè. Gen kontak lokal, pèmi, ak sipò sou teren.',
    200.00,
    'per_day',
    'briefcase'
),
(
    'Vehicle Rental',
    'Location de véhicule',
    'Lwaye machin',
    'Rent a vehicle with or without a driver. Well-maintained vehicles suitable for Haiti''s terrain.',
    'Louez un véhicule avec ou sans chauffeur. Véhicules bien entretenus adaptés au terrain haïtien.',
    'Lwaye yon machin ak oswa san chofè. Machin ki byen antretni ki bon pou teren Ayiti a.',
    80.00,
    'per_day',
    'truck'
),
(
    'Multi-day Package',
    'Forfait plusieurs jours',
    'Pakè plizyè jou',
    'Comprehensive multi-day tour package. Customized itineraries including accommodation, meals, and guided experiences.',
    'Forfait touristique complet de plusieurs jours. Itinéraires personnalisés comprenant l''hébergement, les repas et les expériences guidées.',
    'Pakè konplè pou plizyè jou. Pwogram pèsonalize ki gen lojman, manje, ak eksperyans ak gid.',
    1000.00,
    'per_group',
    'calendar'
);

-- =====================================================
-- SAMPLE ADMIN USER (for testing)
-- =====================================================
-- Note: In production, create admin users through Supabase Auth
-- This is just to show the structure

-- =====================================================
-- SAMPLE LOCATIONS / SERVICE AREAS
-- =====================================================
-- Store service areas as TEXT[] in guide_profiles
-- These are reference values for the application

-- Common service areas:
-- Port-au-Prince (Pòtoprens)
-- Pétion-Ville (Petyonvil)
-- Delmas
-- Carrefour (Kafou)
-- Cap-Haïtien (Kap Ayisyen)
-- Jacmel
-- Les Cayes (Okay)
-- Gonaïves (Gonayiv)
-- Saint-Marc (Sen Mak)
-- Kenscoff
-- Île-à-Vache
-- Labadee
-- Hinche
-- Jérémie
-- Port-de-Paix (Pòdepè)
-- Fort-Liberté

-- =====================================================
-- SAMPLE GUIDE PROFILES (for testing/demo)
-- =====================================================
-- Note: These would be created through the app with real users
-- Including a few examples to demonstrate the structure

-- Example service areas array for guides:
-- ARRAY['Port-au-Prince', 'Pétion-Ville', 'Kenscoff']
-- ARRAY['Cap-Haïtien', 'Labadee']
-- ARRAY['Jacmel', 'Île-à-Vache']
-- ARRAY['Les Cayes', 'Port-Salut']

-- =====================================================
-- HELPFUL FUNCTIONS
-- =====================================================

-- Function to generate booking number
CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS TEXT AS $$
DECLARE
    booking_num TEXT;
    exists_num BOOLEAN;
BEGIN
    LOOP
        -- Generate format: GDY-YYYYMMDD-XXXX (e.g., GDY-20241213-A5F3)
        booking_num := 'GDY-' ||
                      TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
                      UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4));

        -- Check if this booking number already exists
        SELECT EXISTS(SELECT 1 FROM bookings WHERE booking_number = booking_num) INTO exists_num;

        -- Exit loop if unique
        EXIT WHEN NOT exists_num;
    END LOOP;

    RETURN booking_num;
END;
$$ LANGUAGE plpgsql;

-- Function to update guide statistics after new review
CREATE OR REPLACE FUNCTION update_guide_stats_on_review()
RETURNS TRIGGER AS $$
DECLARE
    guide_profile_id UUID;
BEGIN
    -- Get the guide profile ID from the booking
    SELECT guide_id INTO guide_profile_id
    FROM bookings
    WHERE id = NEW.booking_id;

    -- Update guide profile statistics
    UPDATE guide_profiles
    SET
        average_rating = (
            SELECT AVG(overall_rating)::DECIMAL(3,2)
            FROM reviews r
            JOIN bookings b ON r.booking_id = b.id
            WHERE b.guide_id = guide_profile_id
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews r
            JOIN bookings b ON r.booking_id = b.id
            WHERE b.guide_id = guide_profile_id
        )
    WHERE id = guide_profile_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating guide stats on new review
CREATE TRIGGER trigger_update_guide_stats_on_review
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_guide_stats_on_review();

-- Function to update guide booking count
CREATE OR REPLACE FUNCTION update_guide_booking_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Only increment on completed bookings
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE guide_profiles
        SET total_bookings = total_bookings + 1
        WHERE id = NEW.guide_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating guide booking count
CREATE TRIGGER trigger_update_guide_booking_count
AFTER UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION update_guide_booking_count();

-- Function to update conversation last_message_at
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET last_message_at = NOW()
    WHERE id = NEW.conversation_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating conversation timestamp
CREATE TRIGGER trigger_update_conversation_timestamp
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();
