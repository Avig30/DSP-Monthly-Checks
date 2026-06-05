// Type Unions
export type UserRole = 'admin' | 'case_manager' | 'dsp' | 'bcba' | 'sc_portal' | 'family'
export type UserStatus = 'active' | 'inactive' | 'onboarding' | 'terminated'
export type ParticipantStatus = 'active' | 'inactive' | 'onboarding' | 'discharged'
export type ComplianceStatus = 'clear' | 'expiring' | 'expired' | 'flagged' | 'not_started'
export type ReferralStatus = 'new' | 'in_progress' | 'staffing_needed' | 'submitted' | 'approved' | 'rejected'
export type IncidentStatus = 'open' | 'in_progress' | 'resolved' | 'closed'
export type IncidentSeverity = 'low' | 'medium' | 'high' | 'critical'
export type AuthorizationStatus = 'active' | 'expired' | 'pending' | 'exceeded'
export type ServiceNoteStatus = 'draft' | 'submitted' | 'supervisor_review' | 'approved' | 'update_required'
export type QAStatus = 'complete' | 'pending' | 'flagged'
export type HiringStage = 'applied' | 'phone_screen' | 'interview' | 'offer' | 'hired' | 'rejected'
export type InterviewOutcome = 'strong' | 'warm' | 'match' | 'no_match' | 'pending'

// Database Interfaces

export interface Agency {
  id: string
  name: string
  medicaid_id?: string
  address?: string
  city?: string
  state?: string
  zip?: string
  phone?: string
  email?: string
  created_at: string
  updated_at: string
}

export interface UserProfile {
  id: string
  agency_id: string
  role: UserRole
  status: UserStatus
  first_name?: string
  last_name?: string
  email?: string
  phone?: string
  hire_date?: string
  termination_date?: string
  supervisor_id?: string
  created_at: string
  updated_at: string
}

export interface Participant {
  id: string
  agency_id: string
  first_name: string
  last_name: string
  dob?: string
  medicaid_id?: string
  ddd_id?: string
  status: ParticipantStatus
  address?: string
  city?: string
  state?: string
  zip?: string
  phone?: string
  emergency_contact_name?: string
  emergency_contact_phone?: string
  support_coordinator_id?: string
  primary_dsp_id?: string
  program_type?: string
  funding_source?: string
  diagnosis?: string
  created_at: string
  updated_at: string
}

export interface SupportCoordinator {
  id: string
  agency_id: string
  first_name: string
  last_name: string
  email?: string
  phone?: string
  organization?: string
  active: boolean
  created_at: string
  updated_at: string
}

export interface Referral {
  id: string
  agency_id: string
  participant_first_name: string
  participant_last_name: string
  dob?: string
  medicaid_id?: string
  referral_source?: string
  support_coordinator_id?: string
  status: ReferralStatus
  notes?: string
  assigned_cm_id?: string
  intake_date?: string
  program_type?: string
  funding_source?: string
  created_at: string
  updated_at: string
}

export interface ReferralStatusHistory {
  id: string
  referral_id: string
  old_status?: ReferralStatus
  new_status: ReferralStatus
  changed_by?: string
  notes?: string
  created_at: string
}

export interface Employee {
  id: string
  agency_id: string
  user_id?: string
  first_name: string
  last_name: string
  email?: string
  phone?: string
  address?: string
  city?: string
  state?: string
  zip?: string
  hire_date?: string
  termination_date?: string
  status: UserStatus
  role: UserRole
  supervisor_id?: string
  created_at: string
  updated_at: string
}

export interface ComplianceItem {
  id: string
  agency_id: string
  employee_id: string
  item_type: string
  status: ComplianceStatus
  issue_date?: string
  expiration_date?: string
  document_url?: string
  notes?: string
  created_at: string
  updated_at: string
}

export interface MonthlyCheck {
  id: string
  agency_id: string
  employee_id: string
  month: number
  year: number
  completed_by?: string
  completed_at?: string
  notes?: string
  status: 'pending' | 'complete'
  created_at: string
  updated_at: string
}

export interface Interview {
  id: string
  agency_id: string
  applicant_first_name: string
  applicant_last_name: string
  email?: string
  phone?: string
  applied_date?: string
  stage: HiringStage
  outcome?: InterviewOutcome
  interviewer_id?: string
  notes?: string
  interview_date?: string
  offer_date?: string
  hire_date?: string
  created_at: string
  updated_at: string
}

export interface Authorization {
  id: string
  agency_id: string
  participant_id: string
  service_type: string
  authorized_units: number
  used_units: number
  start_date: string
  end_date: string
  status: AuthorizationStatus
  payer?: string
  auth_number?: string
  notes?: string
  created_at: string
  updated_at: string
}

export interface Visit {
  id: string
  agency_id: string
  participant_id: string
  employee_id: string
  authorization_id?: string
  clock_in: string
  clock_out?: string
  location_in?: string
  location_out?: string
  service_type?: string
  units?: number
  notes?: string
  created_at: string
  updated_at: string
}

export interface ServiceNote {
  id: string
  agency_id: string
  participant_id: string
  employee_id: string
  visit_id?: string
  service_date: string
  service_type?: string
  start_time?: string
  end_time?: string
  status: ServiceNoteStatus
  submitted_at?: string
  approved_by?: string
  approved_at?: string
  created_at: string
  updated_at: string
}

export interface ServiceNoteRow {
  id: string
  service_note_id: string
  goal: string
  prompt_level?: string
  response?: string
  percent_correct?: number
  notes?: string
  sort_order: number
  created_at: string
}

export interface Incident {
  id: string
  agency_id: string
  participant_id: string
  reported_by: string
  incident_date: string
  incident_time?: string
  location?: string
  type?: string
  severity: IncidentSeverity
  status: IncidentStatus
  description: string
  immediate_action?: string
  follow_up?: string
  reviewed_by?: string
  reviewed_at?: string
  created_at: string
  updated_at: string
}

export interface QACheckin {
  id: string
  agency_id: string
  participant_id: string
  employee_id: string
  conducted_by: string
  checkin_date: string
  status: QAStatus
  score?: number
  notes?: string
  action_items?: string
  follow_up_date?: string
  created_at: string
  updated_at: string
}

export interface FBA {
  id: string
  agency_id: string
  participant_id: string
  bcba_id: string
  assessment_date: string
  target_behavior?: string
  hypothesis?: string
  antecedents?: string
  consequences?: string
  recommendations?: string
  status: 'draft' | 'complete'
  created_at: string
  updated_at: string
}

export interface BSP {
  id: string
  agency_id: string
  participant_id: string
  bcba_id: string
  fba_id?: string
  effective_date?: string
  review_date?: string
  target_behaviors?: string
  replacement_behaviors?: string
  strategies?: string
  crisis_plan?: string
  status: 'draft' | 'active' | 'archived'
  created_at: string
  updated_at: string
}

export interface ABCData {
  id: string
  agency_id: string
  participant_id: string
  bsp_id?: string
  recorded_by: string
  observation_date: string
  antecedent: string
  behavior: string
  consequence: string
  severity?: string
  duration_minutes?: number
  notes?: string
  created_at: string
}

export interface AuditLog {
  id: string
  agency_id?: string
  user_id?: string
  action: string
  table_name?: string
  record_id?: string
  old_values?: Record<string, any>
  new_values?: Record<string, any>
  ip_address?: string
  created_at: string
}
