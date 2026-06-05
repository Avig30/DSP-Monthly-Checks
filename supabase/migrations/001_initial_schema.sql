-- ============================================================
-- ASG Care Solutions - Initial Schema Migration
-- Run this in Supabase SQL Editor
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PART 1: CREATE ALL TABLES (no policies yet)
-- ============================================================

CREATE TABLE IF NOT EXISTS agencies (
  id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        text NOT NULL,
  medicaid_id text,
  address     text,
  city        text,
  state       text DEFAULT 'NJ',
  zip         text,
  phone       text,
  email       text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_profiles (
  id               uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  agency_id        uuid REFERENCES agencies(id) ON DELETE SET NULL,
  role             text NOT NULL DEFAULT 'dsp'
                   CHECK (role IN ('admin','case_manager','dsp','bcba','sc_portal','family')),
  status           text NOT NULL DEFAULT 'active'
                   CHECK (status IN ('active','inactive','onboarding','terminated')),
  first_name       text,
  last_name        text,
  email            text,
  phone            text,
  hire_date        date,
  termination_date date,
  supervisor_id    uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS support_coordinators (
  id                  uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id           uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  name                text NOT NULL,
  organization        text,
  county              text,
  phone               text,
  email               text,
  relationship_strength text DEFAULT 'new' CHECK (relationship_strength IN ('new','warm','strong')),
  referral_count      int DEFAULT 0,
  last_contact_date   date,
  notes               text,
  created_by          uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS participants (
  id                      uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id               uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  first_name              text NOT NULL,
  last_name               text NOT NULL,
  dob                     date,
  medicaid_id             text,
  ddd_consumer_id         text,
  diagnoses               text[],
  status                  text NOT NULL DEFAULT 'active'
                          CHECK (status IN ('active','inactive','pending','discharged')),
  address                 text,
  city                    text,
  state                   text DEFAULT 'NJ',
  zip                     text,
  county                  text,
  emergency_contact_name  text,
  emergency_contact_phone text,
  emergency_contact_relationship text,
  guardian_name           text,
  guardian_phone          text,
  guardian_type           text,
  assigned_case_manager_id uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_by              uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS referrals (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id            uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  referral_number      text UNIQUE,
  participant_id       uuid REFERENCES participants(id) ON DELETE SET NULL,
  sc_id                uuid REFERENCES support_coordinators(id) ON DELETE SET NULL,
  service_type         text CHECK (service_type IN ('CBS','IS','Respite - In-Home','Life Coaching','Self-Directed')),
  status               text NOT NULL DEFAULT 'new'
                       CHECK (status IN ('new','staffing_needed','active','on_hold','discharged')),
  referral_date        date,
  target_start_date    date,
  priority             text DEFAULT 'medium' CHECK (priority IN ('high','medium','low')),
  assigned_dsp_id      uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  on_hold_reason       text,
  discharge_reason     text,
  notes                text,
  created_by           uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS referral_status_history (
  id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  referral_id uuid NOT NULL REFERENCES referrals(id) ON DELETE CASCADE,
  old_status  text,
  new_status  text NOT NULL,
  changed_by  uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  notes       text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS employees (
  id                        uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id                 uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  user_id                   uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  first_name                text NOT NULL,
  last_name                 text NOT NULL,
  email                     text,
  phone                     text,
  address                   text,
  city                      text,
  state                     text DEFAULT 'NJ',
  zip                       text,
  dob                       date,
  employment_type           text CHECK (employment_type IN ('Full-Time','Part-Time','PRN','Per Diem')),
  status                    text NOT NULL DEFAULT 'onboarding'
                            CHECK (status IN ('active','onboarding','inactive','terminated')),
  county_coverage           text,
  pay_rate                  numeric(6,2),
  is_driver                 boolean DEFAULT false,
  languages_spoken          text[],
  prior_dsp_experience      boolean,
  years_experience          int,
  drivers_license_number    text,
  reliable_transportation   boolean,
  emergency_contact_name    text,
  emergency_contact_phone   text,
  emergency_contact_relationship text,
  created_by                uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at                timestamptz NOT NULL DEFAULT now(),
  updated_at                timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS compliance_items (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id       uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  employee_id     uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  item_type       text NOT NULL,
  status          text NOT NULL DEFAULT 'not_started'
                  CHECK (status IN ('not_started','pending','complete','expired','flagged')),
  initiated_date  date,
  verified_date   date,
  expiration_date date,
  document_url    text,
  verified_by     uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS monthly_checks (
  id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id   uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  employee_id uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  check_type  text NOT NULL,
  run_date    date NOT NULL,
  result      text CHECK (result IN ('clear','match','error','pending')),
  reviewer_id uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  notes       text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS interviews (
  id                    uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id             uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  first_name            text NOT NULL,
  last_name             text NOT NULL,
  dob                   date,
  phone                 text,
  email                 text,
  address               text,
  city                  text,
  state                 text,
  zip                   text,
  emergency_contact_name text,
  emergency_contact_phone text,
  emergency_contact_relationship text,
  position_applied      text,
  employment_type       text,
  availability_days     text[],
  availability_times    text[],
  drivers_license_number text,
  reliable_transportation boolean,
  languages_spoken      text[],
  prior_dsp_experience  boolean,
  years_experience      int,
  references            jsonb,
  score_experience      int,
  score_crisis          int,
  score_advocacy        int,
  score_hipaa           int,
  score_adl             int,
  score_person_centered int,
  score_documentation   int,
  score_availability    int,
  score_notes           jsonb,
  average_score         numeric(3,1),
  recommendation        text CHECK (recommendation IN ('hire','do_not_hire','consider_follow_up')),
  interviewer_notes     text,
  interviewer_id        uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  offer_start_date      date,
  offer_hourly_rate     numeric(6,2),
  offer_employment_type text,
  offer_sent_at         timestamptz,
  offer_signed_at       timestamptz,
  pipeline_status       text DEFAULT 'interview'
                        CHECK (pipeline_status IN ('interview','offer_sent','offer_signed','onboarding','compliance_clearance','active','rejected')),
  employee_id           uuid REFERENCES employees(id) ON DELETE SET NULL,
  created_by            uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS authorizations (
  id                  uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id           uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id      uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  auth_number         text,
  service_type        text,
  procedure_code      text,
  payer               text CHECK (payer IN ('Horizon NJ Health','Aetna Better Health','Amerigroup','WellCare','FFS')),
  authorized_units    numeric(10,2) DEFAULT 0,
  units_used          numeric(10,2) DEFAULT 0,
  start_date          date,
  end_date            date,
  status              text DEFAULT 'active'
                      CHECK (status IN ('active','expiring','exceeded','pending','expired')),
  alert_threshold_pct int DEFAULT 75,
  renewal_submitted   boolean DEFAULT false,
  document_urls       text[],
  created_by          uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS visits (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id       uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id  uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  employee_id     uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  auth_id         uuid REFERENCES authorizations(id) ON DELETE SET NULL,
  scheduled_start timestamptz,
  scheduled_end   timestamptz,
  clock_in_time   timestamptz,
  clock_in_lat    numeric(10,7),
  clock_in_lng    numeric(10,7),
  clock_out_time  timestamptz,
  clock_out_lat   numeric(10,7),
  clock_out_lng   numeric(10,7),
  status          text DEFAULT 'scheduled'
                  CHECK (status IN ('scheduled','in_progress','completed','missed','cancelled')),
  missed_flag     boolean DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS service_notes (
  id               uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id        uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  visit_id         uuid REFERENCES visits(id) ON DELETE SET NULL,
  participant_id   uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  employee_id      uuid NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  auth_id          uuid REFERENCES authorizations(id) ON DELETE SET NULL,
  date_of_service  date NOT NULL,
  shift_start      time,
  shift_end        time,
  total_units      numeric(6,2),
  billable_units   numeric(6,2),
  overall_narrative text,
  status           text DEFAULT 'draft'
                   CHECK (status IN ('draft','submitted','supervisor_review','approved','update_required')),
  supervisor_id    uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  approved_at      timestamptz,
  correction_reason text,
  created_by       uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS service_note_rows (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  note_id              uuid NOT NULL REFERENCES service_notes(id) ON DELETE CASCADE,
  row_date             date,
  start_time           time,
  end_time             time,
  units                numeric(4,2),
  location             text CHECK (location IN ('Home','Community','Worksite','School/Class','Provider Site','Medical/Health Appointment','Day Program','Place of Worship','Recreational Facility','Virtual/Telehealth','Other')),
  activity_category    text CHECK (activity_category IN ('ADL/Personal Care','Community Participation','Independence Skill Building','On-the-Job Support','Learning Activity','Transportation/Travel Training','Health & Safety Support','Behavior Support','Medication Support','Other ISP-Related Support')),
  strategy_adl         boolean DEFAULT false,
  strategy_community   boolean DEFAULT false,
  strategy_independence boolean DEFAULT false,
  strategy_job_support boolean DEFAULT false,
  strategy_learning    boolean DEFAULT false,
  individualized_activity text,
  narrative            text,
  completed_by         text,
  refusal_reason       text,
  billable             boolean,
  billable_error       text,
  supervisor_initials  text,
  supervisor_approved  boolean DEFAULT false,
  created_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS incidents (
  id                      uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id               uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  report_number           text UNIQUE,
  incident_type           text CHECK (incident_type IN ('UIR','IR','Internal')),
  participant_id          uuid REFERENCES participants(id) ON DELETE SET NULL,
  employee_id             uuid REFERENCES employees(id) ON DELETE SET NULL,
  severity                text CHECK (severity IN ('Low','Medium','High','Critical')),
  incident_date           date,
  incident_start_time     time,
  incident_end_time       time,
  location                text,
  incident_categories     text[],
  what_happened           text,
  participant_before      text,
  dsp_actions             text,
  outcome                 text,
  witnesses               jsonb,
  injury_occurred         boolean DEFAULT false,
  body_parts_affected     text[],
  injury_nature           text,
  severity_rating         text,
  first_aid_provided      boolean,
  medical_attention_sought boolean,
  medical_visit_datetime  timestamptz,
  called_911              boolean DEFAULT false,
  contributing_factors    text[],
  follow_up_required      boolean,
  follow_up_description   text,
  pattern_review_needed   boolean,
  care_team_discussion    boolean,
  escalate_to_supervisor  boolean,
  uir_ir_also_filed       boolean,
  isp_bsp_review_needed   boolean,
  bcba_notification       boolean,
  status                  text DEFAULT 'open'
                          CHECK (status IN ('open','aenf_filed','under_review','resolved')),
  corrective_action       text,
  resolved_at             timestamptz,
  supervisor_notified_name text,
  supervisor_notified_time timestamptz,
  supervisor_review_notes text,
  supervisor_reviewed_at  timestamptz,
  dsp_signature           text,
  dsp_signed_at           timestamptz,
  created_by              uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS qa_checkins (
  id                              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id                       uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id                  uuid REFERENCES participants(id) ON DELETE SET NULL,
  case_manager_id                 uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  checkin_date                    date,
  checkin_month                   int,
  checkin_year                    int,
  checkin_method                  text CHECK (checkin_method IN ('In-Person','Phone','Video Call')),
  persons_present                 text[],
  participant_satisfied_services  text CHECK (participant_satisfied_services IN ('Yes','No','Partially')),
  participant_satisfied_dsp       text CHECK (participant_satisfied_dsp IN ('Yes','No','Partially')),
  isp_goals_active                text CHECK (isp_goals_active IN ('Yes','No','Unsure')),
  services_on_schedule            text CHECK (services_on_schedule IN ('Yes','No','Sometimes')),
  overall_satisfaction_rating     int CHECK (overall_satisfaction_rating BETWEEN 1 AND 5),
  health_changes                  boolean,
  health_changes_description      text,
  safety_concerns                 boolean,
  safety_concerns_description     text,
  participant_feels_safe          text,
  behavioral_concerns             boolean,
  behavioral_concerns_description text,
  guardian_contact_name           text,
  guardian_satisfied_communication text,
  guardian_has_concerns           boolean,
  guardian_concerns_description   text,
  participant_changes             boolean,
  participant_changes_description text,
  follow_up_required              boolean,
  follow_up_description           text,
  responsible_party               text,
  escalate_to_supervisor          boolean,
  case_manager_notes              text,
  overall_status                  text CHECK (overall_status IN ('no_concerns','concerns_noted','escalated')),
  signed_at                       timestamptz,
  status                          text DEFAULT 'pending' CHECK (status IN ('pending','completed','overdue')),
  created_at                      timestamptz NOT NULL DEFAULT now(),
  updated_at                      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fbas (
  id                         uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id                  uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id             uuid REFERENCES participants(id) ON DELETE SET NULL,
  bcba_id                    uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  status                     text DEFAULT 'draft'
                             CHECK (status IN ('draft','bcba_review','supervisor_approval','active')),
  indirect_assessment        jsonb,
  descriptive_assessment     jsonb,
  hypothesis_of_function     text,
  bsp_strategy_recommendations text,
  created_by                 uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at                 timestamptz NOT NULL DEFAULT now(),
  updated_at                 timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bsps (
  id                    uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id             uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id        uuid REFERENCES participants(id) ON DELETE SET NULL,
  fba_id                uuid REFERENCES fbas(id) ON DELETE SET NULL,
  bcba_id               uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  level                 text CHECK (level IN ('I','II','III')),
  status                text DEFAULT 'draft'
                        CHECK (status IN ('draft','bcba_review','supervisor_approval','active')),
  content               jsonb,
  next_progress_note_due date,
  bmc_approval_date     date,
  hrc_approval_date     date,
  version               int DEFAULT 1,
  created_by            uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS abc_data (
  id               uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id        uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  participant_id   uuid REFERENCES participants(id) ON DELETE SET NULL,
  bsp_id           uuid REFERENCES bsps(id) ON DELETE SET NULL,
  form_type        text CHECK (form_type IN ('day_program','residential')),
  date             date,
  observer_id      uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  setting          text,
  target_behavior_1 text,
  target_behavior_2 text,
  target_behavior_3 text,
  rows             jsonb,
  daily_totals     jsonb,
  notes            text,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_log (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id    uuid REFERENCES agencies(id) ON DELETE SET NULL,
  table_name   text,
  record_id    uuid,
  action       text,
  old_value    jsonb,
  new_value    jsonb,
  performed_by uuid REFERENCES user_profiles(id) ON DELETE SET NULL,
  performed_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- PART 2: HELPER FUNCTION (after user_profiles exists)
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
-- PART 3: ENABLE RLS ON ALL TABLES
-- ============================================================

ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_coordinators ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE compliance_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE interviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE authorizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_note_rows ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE fbas ENABLE ROW LEVEL SECURITY;
ALTER TABLE bsps ENABLE ROW LEVEL SECURITY;
ALTER TABLE abc_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PART 4: RLS POLICIES (all after function is created)
-- ============================================================

CREATE POLICY "agencies_select" ON agencies FOR SELECT USING (id = get_my_agency_id());
CREATE POLICY "agencies_update" ON agencies FOR UPDATE USING (id = get_my_agency_id());

CREATE POLICY "user_profiles_own" ON user_profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "user_profiles_agency" ON user_profiles FOR SELECT USING (agency_id = get_my_agency_id());
CREATE POLICY "user_profiles_update_own" ON user_profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY "user_profiles_insert" ON user_profiles FOR INSERT WITH CHECK (true);

CREATE POLICY "support_coordinators_agency" ON support_coordinators FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "participants_agency" ON participants FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "referrals_agency" ON referrals FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "referral_status_history_agency" ON referral_status_history FOR ALL USING (
  EXISTS (SELECT 1 FROM referrals r WHERE r.id = referral_status_history.referral_id AND r.agency_id = get_my_agency_id())
);
CREATE POLICY "employees_agency" ON employees FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "compliance_items_agency" ON compliance_items FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "monthly_checks_agency" ON monthly_checks FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "interviews_agency" ON interviews FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "authorizations_agency" ON authorizations FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "visits_agency" ON visits FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "service_notes_agency" ON service_notes FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "service_note_rows_agency" ON service_note_rows FOR ALL USING (
  EXISTS (SELECT 1 FROM service_notes sn WHERE sn.id = service_note_rows.note_id AND sn.agency_id = get_my_agency_id())
);
CREATE POLICY "incidents_agency" ON incidents FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "qa_checkins_agency" ON qa_checkins FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "fbas_agency" ON fbas FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "bsps_agency" ON bsps FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "abc_data_agency" ON abc_data FOR ALL USING (agency_id = get_my_agency_id());
CREATE POLICY "audit_log_select" ON audit_log FOR SELECT USING (agency_id = get_my_agency_id());
CREATE POLICY "audit_log_insert" ON audit_log FOR INSERT WITH CHECK (true);

-- ============================================================
-- PART 5: UPDATED_AT TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'agencies','user_profiles','support_coordinators','participants',
    'referrals','employees','compliance_items','monthly_checks',
    'interviews','authorizations','visits','service_notes',
    'incidents','qa_checkins','fbas','bsps'
  ]
  LOOP
    EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at()', t);
  END LOOP;
END;
$$;
