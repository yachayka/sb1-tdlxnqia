/*
  # Initial Schema Setup for Applicants Management System

  1. New Tables
    - `applicants`: Stores applicant information
    - `programs`: Available academic programs
    - `applications`: Links applicants to programs
    - `documents`: Stores document information
    - `admissions_officers`: Staff information
    - `interviews`: Interview scheduling and results
    - `scholarships`: Available scholarships

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Applicants table
CREATE TABLE applicants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name TEXT NOT NULL,
  birth_date DATE NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
  phone_number TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Programs table
CREATE TABLE programs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  program_name TEXT NOT NULL,
  degree_level TEXT NOT NULL CHECK (degree_level IN ('Bachelor', 'Master', 'PhD')),
  duration_years INTEGER NOT NULL,
  tuition_fee DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Applications table
CREATE TABLE applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  applicant_id UUID REFERENCES applicants(id) ON DELETE CASCADE,
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE,
  application_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status TEXT NOT NULL CHECK (status IN ('Pending', 'Accepted', 'Rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Documents table
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  applicant_id UUID REFERENCES applicants(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL CHECK (document_type IN ('Passport', 'Transcript', 'Recommendation Letter')),
  issued_date DATE NOT NULL,
  expiration_date DATE,
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admissions Officers table
CREATE TABLE admissions_officers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id UUID REFERENCES auth.users(id),
  full_name TEXT NOT NULL,
  position TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone_number TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Interviews table
CREATE TABLE interviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  applicant_id UUID REFERENCES applicants(id) ON DELETE CASCADE,
  officer_id UUID REFERENCES admissions_officers(id) ON DELETE CASCADE,
  interview_date TIMESTAMPTZ NOT NULL,
  result TEXT NOT NULL CHECK (result IN ('Pass', 'Fail', 'Pending')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scholarships table
CREATE TABLE scholarships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE,
  scholarship_name TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  eligibility_criteria TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE applicants ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE admissions_officers ENABLE ROW LEVEL SECURITY;
ALTER TABLE interviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE scholarships ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow authenticated read access" ON applicants
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access" ON programs
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access" ON applications
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access" ON documents
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access" ON admissions_officers
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access" ON interviews
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access" ON scholarships
  FOR SELECT TO authenticated USING (true);

-- Create function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updating timestamps
CREATE TRIGGER update_applicants_updated_at
  BEFORE UPDATE ON applicants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_programs_updated_at
  BEFORE UPDATE ON programs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_admissions_officers_updated_at
  BEFORE UPDATE ON admissions_officers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_interviews_updated_at
  BEFORE UPDATE ON interviews
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_scholarships_updated_at
  BEFORE UPDATE ON scholarships
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();