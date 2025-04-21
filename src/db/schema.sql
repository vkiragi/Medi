-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  streak_days INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_minutes_meditated FLOAT DEFAULT 0,
  level INTEGER DEFAULT 1,
  preferred_categories TEXT[] DEFAULT '{}',
  
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- Create meditation_sessions table
CREATE TABLE meditation_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  duration FLOAT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  attribution TEXT,
  audio_url TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  public BOOLEAN DEFAULT true,
  creator_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  popular BOOLEAN DEFAULT false,
  play_count INTEGER DEFAULT 0
);

-- Create meditation_history table
CREATE TABLE meditation_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  meditation_id UUID REFERENCES meditation_sessions(id) ON DELETE CASCADE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  duration_seconds INTEGER NOT NULL,
  completed BOOLEAN DEFAULT true,
  notes TEXT
);

-- Create favorites table
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  meditation_id UUID REFERENCES meditation_sessions(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure a user can favorite a meditation only once
  UNIQUE(user_id, meditation_id)
);

-- Function to increment meditation play count
CREATE OR REPLACE FUNCTION increment_play_count(meditation_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE meditation_sessions
  SET play_count = play_count + 1
  WHERE id = meditation_id;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meditation_sessions_updated_at
BEFORE UPDATE ON meditation_sessions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;

-- Add RLS policies for profiles
CREATE POLICY "Users can view own profile" 
ON profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);

-- Add RLS policies for meditation_history
CREATE POLICY "Users can view own meditation history" 
ON meditation_history FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meditation history" 
ON meditation_history FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meditation history" 
ON meditation_history FOR UPDATE 
USING (auth.uid() = user_id);

-- Add RLS policies for favorites
CREATE POLICY "Users can view own favorites" 
ON favorites FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites" 
ON favorites FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites" 
ON favorites FOR DELETE 
USING (auth.uid() = user_id);

-- Add RLS policies for meditation_sessions
CREATE POLICY "Anyone can view public meditation sessions" 
ON meditation_sessions FOR SELECT 
USING (public = true);

CREATE POLICY "Users can view their own meditation sessions" 
ON meditation_sessions FOR SELECT 
USING (auth.uid() = creator_id);

CREATE POLICY "Users can insert their own meditation sessions" 
ON meditation_sessions FOR INSERT 
WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can update their own meditation sessions" 
ON meditation_sessions FOR UPDATE 
USING (auth.uid() = creator_id);

CREATE POLICY "Users can delete their own meditation sessions" 
ON meditation_sessions FOR DELETE 
USING (auth.uid() = creator_id);

-- Create a view for recent meditation history
CREATE VIEW recent_meditations AS
SELECT 
  mh.id,
  mh.user_id,
  mh.meditation_id,
  mh.completed_at,
  mh.duration_seconds,
  mh.completed,
  ms.name as meditation_name,
  ms.category,
  ms.duration
FROM 
  meditation_history mh
JOIN
  meditation_sessions ms ON mh.meditation_id = ms.id
WHERE
  mh.completed = true
ORDER BY 
  mh.completed_at DESC;