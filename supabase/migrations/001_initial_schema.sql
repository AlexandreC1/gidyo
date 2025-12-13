-- GIDYO Database Schema
-- Initial migration for the marketplace platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS TABLE (Base table for all user types)
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('visitor', 'guide', 'admin')),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    profile_photo TEXT,
    language_preference VARCHAR(5) DEFAULT 'en' CHECK (language_preference IN ('en', 'fr', 'ht')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_active ON users(is_active);

-- =====================================================
-- GUIDE PROFILES TABLE
-- =====================================================
CREATE TABLE guide_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    video_url TEXT,
    languages TEXT[] DEFAULT ARRAY['ht'],
    service_areas TEXT[] DEFAULT ARRAY[]::TEXT[],
    vehicle_type VARCHAR(50),
    vehicle_capacity INTEGER,
    vehicle_details JSONB,
    certifications JSONB DEFAULT '[]'::JSONB,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verification_date TIMESTAMPTZ,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    stripe_account_id VARCHAR(255),
    moncash_number VARCHAR(50),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX idx_guide_profiles_user ON guide_profiles(user_id);
CREATE INDEX idx_guide_profiles_verification ON guide_profiles(verification_status);
CREATE INDEX idx_guide_profiles_available ON guide_profiles(is_available);
CREATE INDEX idx_guide_profiles_rating ON guide_profiles(average_rating DESC);

-- =====================================================
-- VISITOR PROFILES TABLE
-- =====================================================
CREATE TABLE visitor_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    nationality VARCHAR(100),
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    travel_purpose TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX idx_visitor_profiles_user ON visitor_profiles(user_id);

-- =====================================================
-- SERVICE TYPES TABLE
-- =====================================================
CREATE TABLE service_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_en VARCHAR(200) NOT NULL,
    name_fr VARCHAR(200),
    name_ht VARCHAR(200),
    description_en TEXT,
    description_fr TEXT,
    description_ht TEXT,
    base_price DECIMAL(10,2) DEFAULT 0.00,
    price_unit VARCHAR(50) DEFAULT 'per_person' CHECK (price_unit IN ('per_person', 'per_group', 'per_hour', 'per_day')),
    icon VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_service_types_active ON service_types(is_active);

-- =====================================================
-- GUIDE SERVICES TABLE
-- =====================================================
CREATE TABLE guide_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guide_id UUID NOT NULL REFERENCES guide_profiles(id) ON DELETE CASCADE,
    service_type_id UUID NOT NULL REFERENCES service_types(id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL,
    duration_hours DECIMAL(4,1),
    max_participants INTEGER,
    includes TEXT[] DEFAULT ARRAY[]::TEXT[],
    custom_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(guide_id, service_type_id)
);

CREATE INDEX idx_guide_services_guide ON guide_services(guide_id);
CREATE INDEX idx_guide_services_type ON guide_services(service_type_id);
CREATE INDEX idx_guide_services_active ON guide_services(is_active);

-- =====================================================
-- BOOKINGS TABLE
-- =====================================================
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_number VARCHAR(20) UNIQUE NOT NULL,
    visitor_id UUID NOT NULL REFERENCES visitor_profiles(id) ON DELETE RESTRICT,
    guide_id UUID NOT NULL REFERENCES guide_profiles(id) ON DELETE RESTRICT,
    service_id UUID NOT NULL REFERENCES guide_services(id) ON DELETE RESTRICT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'refunded')),
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    duration_hours DECIMAL(4,1) NOT NULL,
    number_of_participants INTEGER NOT NULL CHECK (number_of_participants > 0),
    pickup_location TEXT,
    pickup_coordinates POINT,
    destination_location TEXT,
    destination_coordinates POINT,
    base_price DECIMAL(10,2) NOT NULL,
    platform_fee DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(255),
    special_requests TEXT,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bookings_visitor ON bookings(visitor_id);
CREATE INDEX idx_bookings_guide ON bookings(guide_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);

-- =====================================================
-- REVIEWS TABLE
-- =====================================================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    overall_rating INTEGER NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    communication_rating INTEGER CHECK (communication_rating BETWEEN 1 AND 5),
    punctuality_rating INTEGER CHECK (punctuality_rating BETWEEN 1 AND 5),
    knowledge_rating INTEGER CHECK (knowledge_rating BETWEEN 1 AND 5),
    value_rating INTEGER CHECK (value_rating BETWEEN 1 AND 5),
    review_text TEXT,
    photos TEXT[] DEFAULT ARRAY[]::TEXT[],
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(booking_id, reviewer_id)
);

CREATE INDEX idx_reviews_booking ON reviews(booking_id);
CREATE INDEX idx_reviews_reviewee ON reviews(reviewee_id);
CREATE INDEX idx_reviews_rating ON reviews(overall_rating DESC);
CREATE INDEX idx_reviews_public ON reviews(is_public);

-- =====================================================
-- CONVERSATIONS TABLE
-- =====================================================
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    visitor_id UUID NOT NULL REFERENCES visitor_profiles(id) ON DELETE CASCADE,
    guide_id UUID NOT NULL REFERENCES guide_profiles(id) ON DELETE CASCADE,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_visitor ON conversations(visitor_id);
CREATE INDEX idx_conversations_guide ON conversations(guide_id);
CREATE INDEX idx_conversations_booking ON conversations(booking_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- =====================================================
-- MESSAGES TABLE
-- =====================================================
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'location', 'system')),
    media_url TEXT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);
CREATE INDEX idx_messages_unread ON messages(is_read) WHERE is_read = false;

-- =====================================================
-- GUIDE AVAILABILITY TABLE
-- =====================================================
CREATE TABLE guide_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guide_id UUID NOT NULL REFERENCES guide_profiles(id) ON DELETE CASCADE,
    day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
    specific_date DATE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK ((day_of_week IS NOT NULL AND specific_date IS NULL) OR (day_of_week IS NULL AND specific_date IS NOT NULL))
);

CREATE INDEX idx_guide_availability_guide ON guide_availability(guide_id);
CREATE INDEX idx_guide_availability_date ON guide_availability(specific_date);
CREATE INDEX idx_guide_availability_day ON guide_availability(day_of_week);

-- =====================================================
-- PAYOUTS TABLE
-- =====================================================
CREATE TABLE payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guide_id UUID NOT NULL REFERENCES guide_profiles(id) ON DELETE RESTRICT,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('stripe', 'moncash', 'bank_transfer')),
    transaction_id VARCHAR(255),
    booking_ids UUID[] DEFAULT ARRAY[]::UUID[],
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payouts_guide ON payouts(guide_id);
CREATE INDEX idx_payouts_status ON payouts(status);
CREATE INDEX idx_payouts_created ON payouts(created_at DESC);

-- =====================================================
-- SAVED GUIDES TABLE (Favorites)
-- =====================================================
CREATE TABLE saved_guides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visitor_id UUID NOT NULL REFERENCES visitor_profiles(id) ON DELETE CASCADE,
    guide_id UUID NOT NULL REFERENCES guide_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(visitor_id, guide_id)
);

CREATE INDEX idx_saved_guides_visitor ON saved_guides(visitor_id);
CREATE INDEX idx_saved_guides_guide ON saved_guides(guide_id);

-- =====================================================
-- NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}'::JSONB,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Guide profiles policies
CREATE POLICY "Anyone can view verified guide profiles" ON guide_profiles
    FOR SELECT USING (verification_status = 'verified' AND is_available = true);

CREATE POLICY "Guides can update their own profile" ON guide_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Guides can insert their own profile" ON guide_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Visitor profiles policies
CREATE POLICY "Visitors can view their own profile" ON visitor_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Visitors can update their own profile" ON visitor_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Visitors can insert their own profile" ON visitor_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Service types policies (public read)
CREATE POLICY "Anyone can view active service types" ON service_types
    FOR SELECT USING (is_active = true);

-- Guide services policies
CREATE POLICY "Anyone can view active guide services" ON guide_services
    FOR SELECT USING (is_active = true);

CREATE POLICY "Guides can manage their own services" ON guide_services
    FOR ALL USING (
        guide_id IN (SELECT id FROM guide_profiles WHERE user_id = auth.uid())
    );

-- Bookings policies
CREATE POLICY "Visitors can view their own bookings" ON bookings
    FOR SELECT USING (
        visitor_id IN (SELECT id FROM visitor_profiles WHERE user_id = auth.uid())
    );

CREATE POLICY "Guides can view their bookings" ON bookings
    FOR SELECT USING (
        guide_id IN (SELECT id FROM guide_profiles WHERE user_id = auth.uid())
    );

CREATE POLICY "Visitors can create bookings" ON bookings
    FOR INSERT WITH CHECK (
        visitor_id IN (SELECT id FROM visitor_profiles WHERE user_id = auth.uid())
    );

CREATE POLICY "Visitors and guides can update their bookings" ON bookings
    FOR UPDATE USING (
        visitor_id IN (SELECT id FROM visitor_profiles WHERE user_id = auth.uid()) OR
        guide_id IN (SELECT id FROM guide_profiles WHERE user_id = auth.uid())
    );

-- Reviews policies
CREATE POLICY "Anyone can view public reviews" ON reviews
    FOR SELECT USING (is_public = true);

CREATE POLICY "Users can create reviews for their bookings" ON reviews
    FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- Conversations policies
CREATE POLICY "Users can view their own conversations" ON conversations
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM visitor_profiles WHERE id = visitor_id
            UNION
            SELECT user_id FROM guide_profiles WHERE id = guide_id
        )
    );

CREATE POLICY "Users can create conversations" ON conversations
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM visitor_profiles WHERE id = visitor_id
            UNION
            SELECT user_id FROM guide_profiles WHERE id = guide_id
        )
    );

-- Messages policies
CREATE POLICY "Users can view messages in their conversations" ON messages
    FOR SELECT USING (
        conversation_id IN (
            SELECT id FROM conversations WHERE
                auth.uid() IN (
                    SELECT user_id FROM visitor_profiles WHERE id = visitor_id
                    UNION
                    SELECT user_id FROM guide_profiles WHERE id = guide_id
                )
        )
    );

CREATE POLICY "Users can send messages in their conversations" ON messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        conversation_id IN (
            SELECT id FROM conversations WHERE
                auth.uid() IN (
                    SELECT user_id FROM visitor_profiles WHERE id = visitor_id
                    UNION
                    SELECT user_id FROM guide_profiles WHERE id = guide_id
                )
        )
    );

-- Guide availability policies
CREATE POLICY "Anyone can view guide availability" ON guide_availability
    FOR SELECT USING (is_available = true);

CREATE POLICY "Guides can manage their own availability" ON guide_availability
    FOR ALL USING (
        guide_id IN (SELECT id FROM guide_profiles WHERE user_id = auth.uid())
    );

-- Payouts policies
CREATE POLICY "Guides can view their own payouts" ON payouts
    FOR SELECT USING (
        guide_id IN (SELECT id FROM guide_profiles WHERE user_id = auth.uid())
    );

-- Saved guides policies
CREATE POLICY "Visitors can view their saved guides" ON saved_guides
    FOR SELECT USING (
        visitor_id IN (SELECT id FROM visitor_profiles WHERE user_id = auth.uid())
    );

CREATE POLICY "Visitors can manage their saved guides" ON saved_guides
    FOR ALL USING (
        visitor_id IN (SELECT id FROM visitor_profiles WHERE user_id = auth.uid())
    );

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_guide_profiles_updated_at BEFORE UPDATE ON guide_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_visitor_profiles_updated_at BEFORE UPDATE ON visitor_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_types_updated_at BEFORE UPDATE ON service_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_guide_services_updated_at BEFORE UPDATE ON guide_services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_guide_availability_updated_at BEFORE UPDATE ON guide_availability
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payouts_updated_at BEFORE UPDATE ON payouts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
