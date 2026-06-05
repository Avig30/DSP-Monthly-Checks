-- ============================================================
-- ASG Care Solutions - Initial Schema Migration
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- HELPER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION get_my_agency_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT agency_id FROM user_profiles WHERE id = auth.uid() LIMIT 1;
$$;

-- ============================================================
-- TABLE: agencies
-- ============================================================

CREATE TABLE IF NOT EXISTS agencies (
  id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          text NOT NULL,
  medicaid_id   text,
  address       text,
  city          text,
  state         text DEFAULT 'NJ',
  zip           text,
  phone         text,
  email         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "agencies_select" ON agencies
  FOR SELECT USING (id = get_my_agency_id());

CREATE POLICY "agencies_update" ON agencies
  FOR UPDATE USING (id = get_my_agency_id());

-- ============================================================
-- TABLE: user_profiles
-- ============================================================

CREATE TABLE IF NOT EXISTS user_profiles (
  id                uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  agency_id         uuid REFERENCES agencies(id) ON DELETE SET NULL,
  role              text NOT NULL DEFAULT 'dsp'
                    CHECK (role IN ('admin','case_manager','dsp','bcba','sc_portal','family')),
  status            text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','inactive','onboarding','terminated')),
  first_name        text,
  last_name         text,
  email             text,
  phone             text,
  hire_date         date,
  termination_date  date,
  supervisor_id     uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_profiles_own" ON user_profiles
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "user_profiles_agency" ON user_profiles
  FOR SELECT USING (agency_id = get_my_agency_id());

CREATE POLICY "user_profiles_update_own" ON user_profiles
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "user_profiles_admin_all" ON user_profiles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles up
      WHERE up.id = auth.uid()
        AND up.agency_id = user_profiles.agency_id
        AND up.role IN ('admin','case_manager')
    )
  );

-- ============================================================
-- TABLE: support_coordinators
-- ============================================================

CREATE TABLE IF NOT EXISTS support_coordinators (
  id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id     uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  first_name    text NOT NULL,
  last_name     text NOT NULL,
  email         text,
  phone         text,
  organization  text,
  active        boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE support_coordinators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "support_coordinators_agency" ON support_coordinators
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: participants
-- ============================================================

CREATE TABLE IF NOT EXISTS participants (
  id                        uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id                 uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  first_name                text NOT NULL,
  last_name                 text NOT NULL,
  dob                       date,
  medicaid_id               text,
  ddd_id                    text,
  status                    text NOT NULL DEFAULT 'active'
                            CHECK (status IN ('active','inactive','onboarding','discharged')),
  address                   text,
  city                      text,
  state                     text DEFAULT 'NJ',
  zip                       text,
  phone                     text,
  emergency_contact_name    text,
  emergency_contact_phone   text,
  support_coordinator_id    uuid REFERENCES support_coordinators(id) ON DELETE SET NULL,
  primary_dsp_id            uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  program_type              text,
  funding_source            text,
  diagnosis                 text,
  created_at                timestamptz NOT NULL DEFAULT now(),
  updated_at                timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "participants_agency" ON participants
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: referrals
-- ============================================================

CREATE TABLE IF NOT EXISTS referrals (
  id                      uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id               uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_first_name  text NOT NULL,
  participant_last_name   text NOT NULL,
  dob                     date,
  medicaid_id             text,
  referral_source         text,
  support_coordinator_id  uuid REFERENCES support_coordinators(id) ON DELETE SET NULL,
  status                  text NOT NULL DEFAULT 'new'
                          CHECK (status IN ('new','in_progress','staffing_needed','submitted','approved','rejected')),
  notes                   text,
  assigned_cm_id          uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  intake_date             date,
  program_type            text,
  funding_source          text,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "referrals_agency" ON referrals
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: referral_status_history
-- ============================================================

CREATE TABLE IF NOT EXISTS referral_status_history (
  id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  referral_id   uuid NOT NULL REFERENCES referrals(id) ON DELETE CASCADE,
  old_status    text,
  new_status    text NOT NULL,
  changed_by    uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referral_status_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "referral_status_history_agency" ON referral_status_history
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM referrals r
      WHERE r.id = referral_status_history.referral_id
        AND r.agency_id = get_my_agency_id()
    )
  );

-- ============================================================
-- TABLE: employees
-- ============================================================

CREATE TABLE IF NOT EXISTS employees (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id         uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  user_id           uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  first_name        text NOT NULL,
  last_name         text NOT NULL,
  email             text,
  phone             text,
  address           text,
  city              text,
  state             text DEFAULT 'NJ',
  zip               text,
  hire_date         date,
  termination_date  date,
  status            text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','inactive','onboarding','terminated')),
  role              text NOT NULL DEFAULT 'dsp'
                    CHECK (role IN ('admin','case_manager','dsp','bcba','sc_portal','family')),
  supervisor_id     uuid REFERENCES employees(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "employees_agency" ON employees
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: compliance_items
-- ============================================================

CREATE TABLE IF NOT EXISTS compliance_items (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id         uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  employee_id       uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  item_type         text NOT NULL,
  status            text NOT NULL DEFAULT 'not_started'
                    CHECK (status IN ('clear','expiring','expired','flagged','not_started')),
  issue_date        date,
  expiration_date   date,
  document_url      text,
  notes             text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE compliance_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "compliance_items_agency" ON compliance_items
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: monthly_checks
-- ============================================================

CREATE TABLE IF NOT EXISTS monthly_checks (
  id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id     uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  employee_id   uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  month         smallint NOT NULL CHECK (month BETWEEN 1 AND 12),
  year          smallint NOT NULL,
  completed_by  uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  completed_at  timestamptz,
  notes         text,
  status        text NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','complete')),
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (employee_id, month, year)
);

ALTER TABLE monthly_checks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "monthly_checks_agency" ON monthly_checks
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: interviews (HR / Hiring)
-- ============================================================

CREATE TABLE IF NOT EXISTS interviews (
  id                    uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id             uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  applicant_first_name  text NOT NULL,
  applicant_last_name   text NOT NULL,
  email                 text,
  phone                 text,
  applied_date          date,
  stage                 text NOT NULL DEFAULT 'applied'
                        CHECK (stage IN ('applied','phone_screen','interview','offer','hired','rejected')),
  outcome               text
                        CHECK (outcome IN ('strong','warm','match','no_match','pending')),
  interviewer_id        uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  notes                 text,
  interview_date        date,
  offer_date            date,
  hire_date             date,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE interviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "interviews_agency" ON interviews
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: authorizations
-- ============================================================

CREATE TABLE IF NOT EXISTS authorizations (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id         uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id    uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  service_type      text NOT NULL,
  authorized_units  numeric(10,2) NOT NULL DEFAULT 0,
  used_units        numeric(10,2) NOT NULL DEFAULT 0,
  start_date        date NOT NULL,
  end_date          date NOT NULL,
  status            text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','expired','pending','exceeded')),
  payer             text,
  auth_number       text,
  notes             text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE authorizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authorizations_agency" ON authorizations
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: visits (EVV)
-- ============================================================

CREATE TABLE IF NOT EXISTS visits (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id         uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id    uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  employee_id       uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  authorization_id  uuid REFERENCES authorizations(id) ON DELETE SET NULL,
  clock_in          timestamptz NOT NULL,
  clock_out         timestamptz,
  location_in       text,
  location_out      text,
  service_type      text,
  units             numeric(10,2),
  notes             text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE visits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "visits_agency" ON visits
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: service_notes
-- ============================================================

CREATE TABLE IF NOT EXISTS service_notes (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id       uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id  uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  employee_id     uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  visit_id        uuid REFERENCES visits(id) ON DELETE SET NULL,
  service_date    date NOT NULL,
  service_type    text,
  start_time      time,
  end_time        time,
  status          text NOT NULL DEFAULT 'draft'
                  CHECK (status IN ('draft','submitted','supervisor_review','approved','update_required')),
  submitted_at    timestamptz,
  approved_by     uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  approved_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE service_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_notes_agency" ON service_notes
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: service_note_rows
-- ============================================================

CREATE TABLE IF NOT EXISTS service_note_rows (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_note_id   uuid NOT NULL REFERENCES service_notes(id) ON DELETE CASCADE,
  goal              text NOT NULL,
  prompt_level      text,
  response          text,
  percent_correct   numeric(5,2),
  notes             text,
  sort_order        integer NOT NULL DEFAULT 0,
  created_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE service_note_rows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_note_rows_agency" ON service_note_rows
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM service_notes sn
      WHERE sn.id = service_note_rows.service_note_id
        AND sn.agency_id = get_my_agency_id()
    )
  );

-- ============================================================
-- TABLE: incidents
-- ============================================================

CREATE TABLE IF NOT EXISTS incidents (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id         uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id    uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  reported_by       uuid NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
  incident_date     date NOT NULL,
  incident_time     time,
  location          text,
  type              text,
  severity          text NOT NULL DEFAULT 'low'
                    CHECK (severity IN ('low','medium','high','critical')),
  status            text NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open','in_progress','resolved','closed')),
  description       text NOT NULL,
  immediate_action  text,
  follow_up         text,
  reviewed_by       uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  reviewed_at       timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "incidents_agency" ON incidents
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: qa_checkins
-- ============================================================

CREATE TABLE IF NOT EXISTS qa_checkins (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id       uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id  uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  employee_id     uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  conducted_by    uuid NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
  checkin_date    date NOT NULL,
  status          text NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('complete','pending','flagged')),
  score           numeric(5,2),
  notes           text,
  action_items    text,
  follow_up_date  date,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE qa_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "qa_checkins_agency" ON qa_checkins
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: fbas (Functional Behavior Assessments)
-- ============================================================

CREATE TABLE IF NOT EXISTS fbas (
  id                uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id         uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id    uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  bcba_id           uuid NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
  assessment_date   date NOT NULL,
  target_behavior   text,
  hypothesis        text,
  antecedents       text,
  consequences      text,
  recommendations   text,
  status            text NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','complete')),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE fbas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "fbas_agency" ON fbas
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: bsps (Behavior Support Plans)
-- ============================================================

CREATE TABLE IF NOT EXISTS bsps (
  id                      uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id               uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id          uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  bcba_id                 uuid NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
  fba_id                  uuid REFERENCES fbas(id) ON DELETE SET NULL,
  effective_date          date,
  review_date             date,
  target_behaviors        text,
  replacement_behaviors   text,
  strategies              text,
  crisis_plan             text,
  status                  text NOT NULL DEFAULT 'draft'
                          CHECK (status IN ('draft','active','archived')),
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE bsps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "bsps_agency" ON bsps
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: abc_data
-- ============================================================

CREATE TABLE IF NOT EXISTS abc_data (
  id                  uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id           uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id      uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  bsp_id              uuid REFERENCES bsps(id) ON DELETE SET NULL,
  recorded_by         uuid NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
  observation_date    date NOT NULL,
  antecedent          text NOT NULL,
  behavior            text NOT NULL,
  consequence         text NOT NULL,
  severity            text,
  duration_minutes    integer,
  notes               text,
  created_at          timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE abc_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "abc_data_agency" ON abc_data
  FOR ALL USING (agency_id = get_my_agency_id());

-- ============================================================
-- TABLE: audit_logs
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_logs (
  id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id     uuid REFERENCES agencies(id) ON DELETE SET NULL,
  user_id       uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  action        text NOT NULL,
  table_name    text,
  record_id     uuid,
  old_values    jsonb,
  new_values    jsonb,
  ip_address    inet,
  created_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_logs_agency" ON audit_logs
  FOR SELECT USING (agency_id = get_my_agency_id());

CREATE POLICY "audit_logs_insert" ON audit_logs
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'agencies','user_profiles','support_coordinators','participants',
    'referrals','employees','compliance_items','monthly_checks',
    'interviews','authorizations','visits','service_notes',
    'incidents','qa_checkins','fbas','bsps'
  ]
  LOOP
    EXECUTE format(
      'CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at()',
      t
    );
  END LOOP;
END;
$$;
