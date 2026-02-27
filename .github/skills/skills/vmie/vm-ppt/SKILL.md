---
name: vm-ppt
description: Create executive PowerPoint presentations using Virgin Media Ireland corporate template with proper VMIE branding, logos, and color scheme.
---

# Virgin Media Ireland Executive Technical Presentations

## Purpose

Create **stunning, executive-ready PowerPoint presentations** from plain text requirements. This skill transforms technical content into professional slide decks optimized for C-level and senior management audiences who need to understand complex technical concepts quickly and make informed decisions.

All presentations must follow **Virgin Media Ireland (VMIE) branding guidelines** with proper logo usage, footer elements, and corporate color scheme.

## Virgin Media Ireland Branding Standards

### Brand Identity
Virgin Media Ireland uses a distinctive brand identity that must be consistently applied:

**Primary Brand Color:**
- **Virgin Media Red**: RGB(225, 10, 10) | Hex: #E10A0A
- This bold red is the signature color for cover slides, section dividers, and high-impact content

**Logo Elements:**
- **Virgin Media Infinity Logo**: The iconic figure-8 infinity symbol with "Virgin" and "media" text
- **Liberty Global Flame Logo**: Parent company logo (orange/white flame icon)
- **Department Label**: "CTIO", "Enterprise Architecture", or appropriate department

### Cover Slide Branding Requirements

The cover slide (first slide) establishes brand presence:

**Visual Structure:**
```
┌────────────────────────────────────────────────────────────┐
│           [VIRGIN MEDIA RED BACKGROUND - FULL SLIDE]        │
│                                                             │
│                                                             │
│                 [Virgin Media Infinity Logo]                │
│                    (centered, white, ~3" wide)              │
│                                                             │
│                                                             │
│                                                             │
│                  [PRESENTATION TITLE]                       │
│               (Large, White, Bold, Centered)                │
│                                                             │
│                     [Subtitle Text]                         │
│                (Medium, White, Centered)                    │
│                                                             │
│                                                             │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

**Specifications:**
- Background: Virgin Media Red (RGB: 225, 10, 10) - full slide
- Virgin Media infinity logo: Centered horizontally at top third, white color, 2.5-3 inches wide
- Title: 44-54pt, white, bold, centered, positioned below logo
- Subtitle: 24-32pt, white, regular weight, centered below title
- NO FOOTER on cover slide (clean, minimal design)
- Large negative space for visual impact

### Footer Specifications (ALL Content Slides)

**CRITICAL**: Every slide except the cover MUST include the branded footer.

**Footer Layout:**
```
Bottom-right corner of slide:
[VM Logo] | [LG Logo] | CTIO    [#]
```

**Detailed Specifications:**
- **Position**: Bottom-right corner with 0.3" margin from edges
- **Virgin Media Logo**: Small infinity logo, 0.35-0.4" height, full color
- **Separator**: Vertical bar "|" in dark gray
- **Liberty Global Logo**: Flame icon (orange circle with white flame), 0.35-0.4" height
- **Separator**: Vertical bar "|" in dark gray  
- **Department**: "CTIO" or relevant dept, 10-11pt, dark gray RGB(100,100,100)
- **Page Number**: Right-aligned, 10-11pt, dark gray

**Implementation Notes:**
- Footers should be subtle, not distracting
- Use consistent sizing across all slides
- Maintain proper spacing between elements (~0.15-0.2" gaps)
- On red background slides, footer elements remain the same (logos + text visible)

### Title Formatting - CRITICAL RULE

**NO FILL AND NO BORDER ON SLIDE TITLES:**

This is extremely important for Virgin Media branding consistency:

✅ **CORRECT Title Formatting:**
- Title text box: **NO background fill** (transparent)
- Title text box: **NO border/outline**
- Text sits directly on slide background (white or red)
- Clean, modern appearance

❌ **INCORRECT Title Formatting:**
- Title with colored background box
- Title with border/outline
- Title in a filled shape

**Implementation:**
```python
# When creating title shapes:
title_shape = slide.shapes.title
title_shape.fill.background()  # No fill
title_shape.line.fill.background()  # No border
```

### Typography Standards

**Slide Titles:**
- Font size: 32-40pt
- Color: Virgin Media Red RGB(225, 10, 10) on white slides, White on red slides
- Weight: Bold
- **NO fill, NO border** (text only)

**Body Text:**
- Font size: 18-24pt (minimum 18pt for readability)
- Color: Dark gray RGB(45, 45, 45) on white, White on red
- Weight: Regular

**Emphasis Text:**
- Use bold selectively for key terms
- Use Virgin Media Red for important callouts on white backgrounds

### Color Palette

**Primary Colors:**
- Virgin Media Red: RGB(225, 10, 10)
- White: RGB(255, 255, 255)
- Dark Gray (text): RGB(45, 45, 45)
- Medium Gray (subtle elements): RGB(100, 100, 100)

**Diagram/Chart Accent Colors:**
- Blue: RGB(52, 152, 219)
- Green: RGB(46, 204, 113)
- Orange: RGB(243, 156, 18)
- Purple: RGB(155, 89, 182)
- Teal: RGB(26, 188, 156)

## When to Use This Skill

Use this skill for creating presentations about:
- Enterprise architecture initiatives
- Solution architecture proposals  
- Cloud migration strategies
- System integration projects
- Technology modernization
- Security and compliance
- Network architecture
- Platform implementations
- Technical roadmaps
- Vendor evaluations
- Any technical topic requiring executive approval

## Input Format

Users will provide **plain text requirements** describing the presentation need, optionally with diagram images.

**Example Input:**
```
Topic: Contact Center Cloud Migration
Need to present to board about moving from Avaya to Genesys Cloud
Current system is 12 years old, costing €7.2M annually
Migration will cost €4.5M but save €2.1M per year
Takes 9 months, some risk with agent adoption
Need approval by March 15
```

## Template Layout Reference

The VMIE template provides 18 pre-designed layouts:

| Index | Layout Name | Primary Use |
|-------|-------------|-------------|
| 0 | Cover Slide Red | Presentation opening |
| 1 | Cover Slide Plum | Alternative cover (less common) |
| 2 | Section Divider Red | Major section transitions |
| 3 | Section Divider Plum | Alternative sections |
| 4 | Text Content - One Column | **Primary workhorse** (80% of slides) |
| 5 | Text Content - Two Columns | Comparisons, before/after |
| 6 | Text Content - Three Columns | Multi-option analysis |
| 7 | Title Only | Architecture diagrams, charts |
| 8 | Blank | Custom layouts |
| 9 | Content on Red | High-impact messages |
| 10 | Content on Plum | Strategic themes |
| 11-17 | Specialty Layouts | Various split and image layouts |

**Most Common Usage Pattern:**
- Cover Slide Red (1 slide)
- Text Content - One Column (10-12 slides)
- Text Content - Two Columns (2-3 slides)
- Title Only for diagrams (2-3 slides)
- Section Divider Red (1-2 slides for appendix)

## Core Presentation Principles

### Executive Communication Rules

1. **5-Second Test**: Main point must be clear in 5 seconds
2. **Business First**: Lead with business value, not technical specs
3. **Quantify Everything**: Use numbers, percentages, specific costs
4. **One Message Per Slide**: Multiple messages = multiple slides
5. **Respect Time**: Be concise, 2-3 minutes per slide maximum

### Content Structure Philosophy

For executives, always structure as:
1. **WHY** - Business problem and impact
2. **WHAT** - Proposed solution  
3. **HOW** - Implementation approach
4. **DECISION** - What approval is needed

## Mandatory Slide Sequence

Every executive technical presentation follows this structure:

### 1. Cover Slide
**Layout**: Cover Slide Red (Layout 0)

**Content:**
- Virgin Media logo centered at top
- Clear, business-focused title (not technical jargon)
- Subtitle with context
- Full red background
- NO footer

**Example:**
```
Title: "Contact Center Cloud Migration Strategy"
Subtitle: "Moving to Genesys Cloud CCaaS Platform"
```

### 2. Executive Summary
**Layout**: Text Content - One Column (Layout 4)  
**Title**: "Executive Summary" (red text, NO fill, NO border)

**Required Content Structure:**
```
Situation: [Current state in 1 sentence]

Challenge: [The problem in 1 sentence]

Recommendation: [Proposed solution in 1 sentence]

Business Impact:
• [Quantified benefit 1]
• [Quantified benefit 2]
• [Quantified benefit 3]

Investment Required: [Cost and timeline]

Key Risk: [Top concern with mitigation]
```

**Example:**
```
Situation: Current Avaya contact center is 12 years old with €7.2M annual operating costs

Challenge: Customer satisfaction declining 15% YoY due to limited omnichannel capabilities

Recommendation: Migrate to Genesys Cloud CCaaS with 9-month phased implementation

Business Impact:
• €2.1M annual cost reduction (29% savings)
• 25% improvement in first-call resolution
• Deploy new features in weeks vs. months

Investment Required: €4.5M capital, 9-month timeline, 27-month ROI

Key Risk: Agent adoption - mitigated via 6-week training program with parallel operation period
```

### 3. Current State / Problem Statement
**Layout**: Text Content - One Column (Layout 4)
**Title**: "Current State Challenges" or "Why Change is Needed"

**Content Focus:**
- Specific technical limitations
- Quantified business impacts  
- Cost escalation data
- Customer/user feedback
- Security or compliance gaps
- Market competitive pressure

**Format:** 4-6 bullet points with metrics

### 4. Proposed Solution
**Layout**: Text Content - One Column (Layout 4)
**Title**: "Proposed Solution" or "Recommended Approach"

**Content in Business Terms:**
- What we're doing (high-level)
- How it solves the stated problems
- Why this approach vs. alternatives
- Key capabilities delivered
- Expected outcomes

**Avoid**: Technical jargon, implementation details (save for appendix)

### 5. Architecture Diagram
**Layout**: Title Only (Layout 7)
**Title**: "Solution Architecture" or "Technical Architecture Overview"

**If Diagram Provided by User:**
- Insert high-resolution image (PNG/JPG)
- Ensure diagram follows enterprise architecture best practices (see section below)
- Image should fill most of slide with appropriate margins

**If NO Diagram:**
- Create text-based component overview
- List major components and integrations
- Note: "Detailed architecture diagram in Appendix"

### 6. Implementation Approach
**Layout**: Text Content - Two Columns (Layout 5) or Three Columns (Layout 6)
**Title**: "Implementation Roadmap" or "Phased Delivery Approach"

**Structure:** 2-3 phases shown as columns

**Each Phase Includes:**
- Phase name and duration
- Key deliverables (3-4 items)
- Business value unlocked
- Success criteria

**Example:**
```
Column 1 - Phase 1: Foundation (Months 1-3)
• Network and infrastructure setup
• Pilot with 20 agents
• Initial CRM integration
• Training program launch

Column 2 - Phase 2: Rollout (Months 4-7)  
• Migrate 150 agents (80%)
• Omnichannel activation
• Full system integration
• Performance monitoring

Column 3 - Phase 3: Optimize (Months 8-9)
• Final 40 agents migrated
• AI/automation features
• Legacy decommission
• Hypercare support
```

### 7. Business Benefits
**Layout**: Text Content - One Column (Layout 4)
**Title**: "Business Benefits" or "Expected Outcomes"

**Categories to Address:**
- **Financial**: Cost savings, ROI, revenue impact
- **Operational**: Efficiency, speed, productivity
- **Strategic**: Scalability, competitive advantage, innovation
- **Risk**: Compliance, security, reliability

**Format:** 4-6 bullets with specific quantification

**Example:**
```
• Financial: €2.1M annual OPEX reduction (29%); 27-month ROI; avoid €1.8M infrastructure refresh
• Operational: 25% improvement in first-call resolution; 20% faster average handle time
• Customer Experience: Project NPS increase from 28 to 45; 50% reduction in wait times
• Strategic: Deploy features in weeks not months; scale instantly for demand spikes
```

### 8. Investment & Resources
**Layout**: Text Content - Two Columns (Layout 5)
**Title**: "Investment Required"

**Left Column - Financial:**
- Capital expenditure breakdown
- Operating expense changes
- Total Cost of Ownership (3-5 years)
- ROI timeline

**Right Column - Resources:**
- Internal team requirements
- External vendors/consultants
- Training needs
- Ongoing support model

### 9. Risks & Mitigation
**Layout**: Content on Red (Layout 9) - High Impact
**Title**: "Key Risks & Mitigation Strategies"

**Format:** 4-5 top risks with mitigation

**Structure:**
```
• [Risk Name] (IMPACT LEVEL): [Description] - Mitigation: [Specific strategy]
```

**Example:**
```
• Agent Adoption (HIGH): Resistance to new platform impacting productivity - Mitigation: 6-week training program, super-user network, 4-week parallel operation, executive sponsorship

• Integration Complexity (MEDIUM): Legacy CRM integration challenges - Mitigation: Technical proof-of-concept completed, Genesys specialists engaged, fallback procedures documented

• Data Migration (MEDIUM): Customer data integrity risks - Mitigation: Full data audit, 3 dry-run migrations, validation checkpoints, verified rollback plan
```

### 10. Recommendations & Next Steps
**Layout**: Content on Red (Layout 9) or Content on Plum (Layout 10)
**Title**: "Recommendations" or "Proposed Next Steps"

**Clear Call to Action:**
```
Recommendation: [Specific approval being sought]

Decision Timeline: [When decision is needed and why]

Immediate Next Steps:
• [Action 1] - [Owner] ([Date])
• [Action 2] - [Owner] ([Date])
• [Action 3] - [Owner] ([Date])

Success Metrics: [How progress will be measured]
```

### 11. Appendix Divider
**Layout**: Section Divider Red (Layout 2)
**Title**: "Appendix"
**Subtitle**: "Supporting Details & Technical Information"

### 12+. Appendix Slides
**Layout**: Various (primarily One Column, Two Column, Title Only)

**Typical Appendix Content:**
- Detailed cost breakdowns
- Vendor comparison matrices
- Detailed project timeline/Gantt
- Technical specifications
- Compliance/security details
- Integration architecture details
- Risk register (full)
- Reference customer case studies

## Enterprise Architecture Diagrams

### Why Diagrams Matter for Executives

Executives are visual thinkers. A well-designed architecture diagram communicates in 30 seconds what would take 10 minutes to explain in text. However, bad diagrams confuse and undermine credibility.

### Core Diagram Design Principles

#### 1. Simplicity Over Completeness
- **Maximum 7-9 major components** visible in main diagram
- Hide implementation details in appendix "zoom-in" views
- Focus on business capabilities, not technical protocols
- Use familiar metaphors (layers, flows, zones)

#### 2. Visual Hierarchy  
- **Size**: Larger boxes for more important/central components
- **Color**: Consistent scheme (see color guide below)
- **Position**: Most critical components at center or top
- **Grouping**: Related components visually clustered

#### 3. Clear Communication
- Every box must be labeled (no mystery components)
- Every arrow must show direction and purpose
- Include a legend for symbols and colors
- Use consistent shapes for consistent types

### Architecture Diagram Types

#### Type 1: Solution Architecture
**Purpose**: Show high-level system components and interactions

**Layers to Include:**
```
┌─────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                      │
│ Web UI | Mobile Apps | APIs | Partner Portals          │
├─────────────────────────────────────────────────────────┤
│ APPLICATION LAYER                                       │
│ Business Logic | Microservices | Application Servers    │
├─────────────────────────────────────────────────────────┤
│ INTEGRATION LAYER                                       │
│ API Gateway | ESB | Message Queues | Event Streams      │
├─────────────────────────────────────────────────────────┤
│ DATA LAYER                                              │
│ Databases | Data Warehouse | Data Lake | Cache          │
├─────────────────────────────────────────────────────────┤
│ INFRASTRUCTURE LAYER                                    │
│ Cloud Platform | Network | Security | Monitoring        │
└─────────────────────────────────────────────────────────┘
```

**Best Practices:**
- Group by logical tiers/layers
- Show data flow with directional arrows
- Label connections (HTTP REST, Database, Message Queue, etc.)
- Use consistent shapes: Rectangles for apps, Cylinders for databases, Clouds for cloud services
- Include legend

**Color Coding:**
- Presentation Layer: Blue RGB(52, 152, 219)
- Application Layer: Green RGB(46, 204, 113)
- Integration Layer: Orange RGB(243, 156, 18)
- Data Layer: Purple RGB(155, 89, 182)
- Infrastructure Layer: Gray RGB(149, 165, 166)

#### Type 2: Enterprise Architecture
**Purpose**: Show how systems interact across the enterprise

**Components:**
- **Business Capabilities**: Customer Mgmt, Billing, Network Ops, etc.
- **Applications**: SAP, Salesforce, ServiceNow, custom apps
- **Integration Patterns**: Hub-spoke, event-driven, API-led
- **Data Domains**: Customer, Network, Financial, Operational
- **External Systems**: Partners, vendors, regulators

**Structure:**
```
BUSINESS LAYER: Capabilities mapped to business processes
     ↓ ↑ (bidirectional arrows)
APPLICATION LAYER: Enterprise applications
     ↓ ↑
INTEGRATION LAYER: ESB, API gateway, event mesh
     ↓ ↑
DATA LAYER: Master data, operational databases
     ↓ ↑
INFRASTRUCTURE LAYER: Hosting, network, security
```

**Key Elements:**
- Show cross-domain interactions
- Highlight integration bottlenecks or single points of failure
- Use color to distinguish internal vs. external systems
- Show data governance/ownership boundaries

#### Type 3: Network Architecture
**Purpose**: Show network topology and connectivity for telecom/infrastructure

**Zones to Depict:**
```
INTERNET / WAN
       ↓
┌─────────────────────────────────┐
│  EXTERNAL ZONE                  │  
│  (Firewalls, WAF, Load Balancers) │
└─────────────────────────────────┘
       ↓
┌─────────────────────────────────┐
│  DMZ                            │
│  (Web Servers, API Gateways)    │
└─────────────────────────────────┘
       ↓
┌─────────────────────────────────┐
│  INTERNAL ZONE                  │
│  (App Servers, Services)        │
└─────────────────────────────────┘
       ↓
┌─────────────────────────────────┐
│  SECURE ZONE                    │
│  (Databases, PII, Compliance)   │
└─────────────────────────────────┘
```

**Components:**
- Firewalls (show as hexagons)
- Load balancers
- Servers (application, database)
- Cloud connectivity (AWS Direct Connect, Azure ExpressRoute)
- Backup/DR sites
- Network paths and protocols

**Security Emphasis:**
- Use red for security controls/firewalls
- Show security zones clearly separated
- Indicate encryption (lock icons, "TLS/SSL" labels)
- Show monitoring/logging points

#### Type 4: Data Flow Diagram
**Purpose**: Show how data moves and transforms

**Elements:**
- **Data Sources**: Systems generating data
- **Transformation**: ETL processes, cleansing, enrichment
- **Storage**: Staging, operational DB, warehouse, lake
- **Consumption**: Applications, analytics, reporting
- **Governance**: Quality checks, compliance controls

**Flow Indicators:**
- Solid thick arrows: High-volume real-time data
- Solid thin arrows: Low-volume real-time
- Dashed arrows: Batch/scheduled processes
- Arrow labels: Data volumes, frequency (e.g., "500GB daily", "Real-time events")

**Include:**
- Data volumes and frequency
- Latency requirements (real-time vs. batch)
- Data quality checkpoints
- Compliance/encryption points

#### Type 5: Integration Architecture
**Purpose**: Show how systems integrate and communicate

**Integration Patterns:**
- **Point-to-Point**: Direct connections (show as direct arrows)
- **Hub-and-Spoke**: Central ESB or integration hub
- **Event-Driven**: Event broker/message queue at center
- **API-Led**: API gateway fronting all integrations
- **Hybrid**: Combination of patterns

**Show:**
- Integration protocols (REST, SOAP, MQTT, FTP, Database)
- Message formats (JSON, XML, CSV, Binary)
- Sync vs. async communication
- Error handling/retry logic
- Monitoring points

**Visual Pattern:**
```
     [System A] ──REST──→ [API Gateway] ──GraphQL──→ [System B]
                                ↓ ↑
                          [Event Queue]
                                ↓ ↑
     [System C] ──SOAP──→ [ESB] ──Database──→ [System D]
```

#### Type 6: Cloud Migration Architecture (Before/After)
**Purpose**: Show transformation from current to future state

**Create TWO side-by-side diagrams or sequential slides:**

**Slide 1 - Current State ("As-Is"):**
- On-premise data centers
- Legacy monolithic applications
- Point-to-point integrations
- Traditional infrastructure

**Slide 2 - Future State ("To-Be"):**
- Cloud-native architecture
- Microservices
- API-driven integrations
- Serverless/containers

**Migration Strategies to Illustrate:**
- **Rehost**: Lift-and-shift VMs to cloud (quick wins)
- **Replatform**: Minor optimizations (managed databases)
- **Refactor**: Rebuild as cloud-native (containers, serverless)
- **Replace**: Move to SaaS (Salesforce, Workday)
- **Retire**: Decommission legacy systems

**Use arrows or color coding to show migration path**

#### Type 7: Security Architecture
**Purpose**: Show defense-in-depth security layers

**Security Layers (outside-in):**
```
1. PERIMETER SECURITY
   Firewalls, WAF, DDoS protection, CDN

2. NETWORK SECURITY  
   VPNs, microsegmentation, IDS/IPS

3. APPLICATION SECURITY
   WAF, API security, input validation

4. IDENTITY SECURITY
   SSO, MFA, RBAC, privileged access mgmt

5. DATA SECURITY
   Encryption at rest/transit, data masking, DLP

6. MONITORING & RESPONSE
   SIEM, SOC, incident response, threat intel
```

**Visual Approach:**
- Concentric circles/layers showing defense-in-depth
- Different colors for each security domain
- Icons for security controls (lock, shield, eye)
- Show compliance zones (PCI, GDPR, etc.)

### Diagram Shape Conventions

Use consistent shapes for consistent meaning:

**Rectangles**: Applications, services, microservices
**Rectangles with double border**: External/third-party systems
**Cylinders**: Databases, data stores
**Cloud shapes**: Cloud services (AWS, Azure, GCP)
**Circles**: API endpoints, web services
**Hexagons**: Security controls, firewalls
**Diamonds**: Decision points, gateways, routers
**Document icon**: Files, reports, documents
**Person icon**: Users, admins, operators
**Gear icon**: Automation, orchestration, workflows

### Arrow Conventions

**Solid Arrow**: Synchronous request-response
**Dashed Arrow**: Asynchronous fire-and-forget
**Thick Arrow**: High-volume data flow
**Thin Arrow**: Low-volume or occasional
**Bi-directional**: Two-way communication
**Color-coded**: HTTP=Blue, Database=Purple, File=Green, Message Queue=Orange

### Color Strategy for Diagrams

**Functional Layers:**
- Blue: User-facing, presentation
- Green: Business logic, applications
- Orange: Integration, middleware
- Purple: Data, storage
- Gray: Infrastructure, platform
- Yellow: External, third-party

**Virgin Media Brand Integration:**
- Use Virgin Media Red for critical path or primary user flows
- Use red to highlight problem areas in current state
- Use red for high-priority/high-risk components

**Status Indicators:**
- Green: New/to be built
- Blue: Existing/current
- Red: To be retired/deprecated
- Yellow: Third-party/external

### Creating Professional Diagrams

#### Recommended Tools

**1. Draw.io (diagrams.net)** - FREE
- Web-based or desktop
- Extensive shape libraries
- Export high-res PNG/JPG
- Collaborative editing

**2. Lucidchart** - PAID
- Enterprise collaboration
- Template library
- Real-time co-authoring
- Integrations with Confluence, etc.

**3. Microsoft Visio** - PAID
- Industry standard
- Extensive stencils
- Integration with Office
- Professional quality

**4. ArchiMate/Sparx EA** - ENTERPRISE
- For formal enterprise architecture
- Standards-based modeling
- Traceability and governance

**5. PowerPoint SmartArt** - INCLUDED
- For simple diagrams
- Limited but integrated
- Good for quick concepts

#### Export Settings for PowerPoint

**Critical Settings:**
- **Format**: PNG (best) or JPG
- **Resolution**: 300 DPI minimum for print quality
- **Size**: 10-11 inches width (fits standard slide with margins)
- **Background**: Transparent PNG preferred, or white
- **Compression**: Minimal (high quality)

#### Diagram Quality Checklist

Before including any diagram:
- [ ] All components are labeled clearly
- [ ] Legend explains all symbols and colors
- [ ] Arrows show direction and are labeled
- [ ] Text is readable (minimum 14pt equivalent)
- [ ] No more than 9 major components visible
- [ ] Color scheme is consistent and meaningful
- [ ] Spacing and alignment are professional
- [ ] No clipart or unprofessional graphics
- [ ] High resolution (no pixelation when projected)
- [ ] Virgin Media branding colors used appropriately

### Text-Based Diagram Alternative

If no diagram tool is available, create a structured text representation:

```
SOLUTION ARCHITECTURE

Presentation Tier:
• Web Portal (Customer-facing UI)
• Mobile App (iOS/Android)
• REST API (Partner integration)
    ↓ HTTPS/REST
Application Tier:
• Order Management Service
• Customer Profile Service  
• Billing Service
    ↓ API Calls
Integration Tier:
• API Gateway (Kong)
• Message Queue (RabbitMQ)
    ↓ Various protocols
Data Tier:
• Customer Database (PostgreSQL)
• Order Database (MongoDB)
• Data Warehouse (Snowflake)
    ↓ Hosted on
Infrastructure:
• AWS Cloud (eu-west-1)
• Network: VPC with private subnets
• Security: WAF, encryption at rest/transit
```

This text-based approach works for appendix slides, but for executive slides, invest in creating visual diagrams.

## Python Implementation

### Setup and Libraries

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
import os
from datetime import datetime

# Virgin Media Brand Colors
VM_RED = RGBColor(225, 10, 10)
VM_WHITE = RGBColor(255, 255, 255)
VM_DARK_GRAY = RGBColor(45, 45, 45)
VM_MEDIUM_GRAY = RGBColor(100, 100, 100)

# Template path
TEMPLATE_PATH = '/mnt/user-data/uploads/VMIE_Powerpoint_Template.pptx'
```

### Core Functions

#### Load Template

```python
def create_presentation(template_path=TEMPLATE_PATH):
    """
    Load VMIE template and return presentation object with layout shortcuts
    
    Returns:
        prs: Presentation object
        layouts: Dictionary of layout shortcuts
    """
    prs = Presentation(template_path)
    
    # Create easy-to-use layout dictionary
    layouts = {
        'cover_red': prs.slide_layouts[0],
        'cover_plum': prs.slide_layouts[1],
        'section_red': prs.slide_layouts[2],
        'section_plum': prs.slide_layouts[3],
        'one_column': prs.slide_layouts[4],
        'two_column': prs.slide_layouts[5],
        'three_column': prs.slide_layouts[6],
        'title_only': prs.slide_layouts[7],
        'blank': prs.slide_layouts[8],
        'content_red': prs.slide_layouts[9],
        'content_plum': prs.slide_layouts[10],
        'white_red': prs.slide_layouts[11],
        'white_plum': prs.slide_layouts[12],
    }
    
    return prs, layouts
```

#### Remove Title Fill and Border

```python
def format_title_no_fill(title_shape):
    """
    CRITICAL: Remove fill and border from title shape per Virgin Media branding
    
    Args:
        title_shape: The title shape object from slide
    """
    # Remove fill
    title_shape.fill.background()
    
    # Remove border/line
    title_shape.line.fill.background()
```

#### Cover Slide

```python
def add_cover_slide(prs, layouts, title, subtitle):
    """
    Add Virgin Media branded cover slide
    
    Args:
        prs: Presentation object
        layouts: Layout dictionary
        title: Main presentation title
        subtitle: Subtitle or context
        
    Returns:
        slide: Created slide object
    """
    slide = prs.slides.add_slide(layouts['cover_red'])
    
    # Set title
    title_shape = slide.shapes.title
    title_shape.text = title
    title_shape.text_frame.paragraphs[0].font.size = Pt(48)
    title_shape.text_frame.paragraphs[0].font.bold = True
    title_shape.text_frame.paragraphs[0].font.color.rgb = VM_WHITE
    
    # Find and set subtitle
    for shape in slide.placeholders:
        if shape.placeholder_format.type == 4:  # SUBTITLE
            shape.text = subtitle
            shape.text_frame.paragraphs[0].font.size = Pt(28)
            shape.text_frame.paragraphs[0].font.color.rgb = VM_WHITE
            break
    
    # NOTE: Template should already have Virgin Media logo
    # If not, logo would need to be added programmatically here
    
    return slide
```

#### Executive Summary Slide

```python
def add_executive_summary(prs, layouts, situation, challenge, recommendation,
                         business_impact_list, investment, key_risk):
    """
    Add executive summary slide with standard structure
    
    Args:
        prs: Presentation object
        layouts: Layout dictionary
        situation: Current state (string)
        challenge: Problem statement (string)
        recommendation: Proposed solution (string)
        business_impact_list: List of benefit strings
        investment: Cost and timeline (string)
        key_risk: Top risk with mitigation (string)
    """
    slide = prs.slides.add_slide(layouts['one_column'])
    
    # Set title with NO FILL, NO BORDER
    title_shape = slide.shapes.title
    title_shape.text = "Executive Summary"
    format_title_no_fill(title_shape)
    title_shape.text_frame.paragraphs[0].font.size = Pt(36)
    title_shape.text_frame.paragraphs[0].font.color.rgb = VM_RED
    title_shape.text_frame.paragraphs[0].font.bold = True
    
    # Find content placeholder
    content = None
    for shape in slide.placeholders:
        if shape.placeholder_format.type == 2:  # BODY
            content = shape
            break
    
    if content:
        tf = content.text_frame
        tf.clear()
        
        # Situation
        p = tf.paragraphs[0]
        p.text = f"Situation: {situation}"
        p.font.size = Pt(20)
        p.font.color.rgb = VM_DARK_GRAY
        p.space_after = Pt(12)
        
        # Challenge
        p = tf.add_paragraph()
        p.text = f"Challenge: {challenge}"
        p.font.size = Pt(20)
        p.font.color.rgb = VM_DARK_GRAY
        p.space_after = Pt(12)
        
        # Recommendation
        p = tf.add_paragraph()
        p.text = f"Recommendation: {recommendation}"
        p.font.size = Pt(20)
        p.font.color.rgb = VM_DARK_GRAY
        p.space_after = Pt(16)
        
        # Business Impact header
        p = tf.add_paragraph()
        p.text = "Business Impact:"
        p.font.size = Pt(20)
        p.font.bold = True
        p.font.color.rgb = VM_DARK_GRAY
        p.space_after = Pt(6)
        
        # Impact bullets
        for impact in business_impact_list:
            p = tf.add_paragraph()
            p.text = impact
            p.level = 1
            p.font.size = Pt(18)
            p.font.color.rgb = VM_DARK_GRAY
        
        # Space before investment
        p = tf.add_paragraph()
        p.text = ""
        p.space_after = Pt(8)
        
        # Investment
        p = tf.add_paragraph()
        p.text = f"Investment Required: {investment}"
        p.font.size = Pt(20)
        p.font.color.rgb = VM_DARK_GRAY
        p.space_after = Pt(12)
        
        # Key Risk
        p = tf.add_paragraph()
        p.text = f"Key Risk: {key_risk}"
        p.font.size = Pt(20)
        p.font.color.rgb = VM_DARK_GRAY
    
    return slide
```

#### Standard Content Slide

```python
def add_content_slide(prs, layouts, title, bullets, use_red_background=False):
    """
    Add content slide with bullet points
    
    Args:
        prs: Presentation object
        layouts: Layout dictionary
        title: Slide title
        bullets: List of strings or tuples (main_text, [sub_bullets])
        use_red_background: Use red background for high-impact slides
        
    Returns:
        slide: Created slide object
    """
    layout = layouts['content_red'] if use_red_background else layouts['one_column']
    slide = prs.slides.add_slide(layout)
    
    # Set title with NO FILL, NO BORDER
    title_shape = slide.shapes.title
    title_shape.text = title
    format_title_no_fill(title_shape)
    title_shape.text_frame.paragraphs[0].font.size = Pt(36)
    title_shape.text_frame.paragraphs[0].font.bold = True
    
    if use_red_background:
        title_shape.text_frame.paragraphs[0].font.color.rgb = VM_WHITE
    else:
        title_shape.text_frame.paragraphs[0].font.color.rgb = VM_RED
    
    # Find content placeholder
    content = None
    for shape in slide.placeholders:
        if shape.placeholder_format.type == 2:  # BODY
            content = shape
            break
    
    if content:
        tf = content.text_frame
        tf.clear()
        
        text_color = VM_WHITE if use_red_background else VM_DARK_GRAY
        
        for idx, bullet in enumerate(bullets):
            if idx == 0:
                p = tf.paragraphs[0]
            else:
                p = tf.add_paragraph()
            
            if isinstance(bullet, tuple):
                # Main bullet with sub-bullets
                main_text, sub_bullets = bullet
                p.text = main_text
                p.level = 0
                p.font.size = Pt(20)
                p.font.color.rgb = text_color
                
                for sub in sub_bullets:
                    p = tf.add_paragraph()
                    p.text = sub
                    p.level = 1
                    p.font.size = Pt(18)
                    p.font.color.rgb = text_color
            else:
                # Simple bullet
                p.text = bullet
                p.level = 0
                p.font.size = Pt(20)
                p.font.color.rgb = text_color
    
    return slide
```

#### Two-Column Comparison Slide

```python
def add_two_column_slide(prs, layouts, title, left_header, left_bullets,
                         right_header, right_bullets):
    """
    Add two-column comparison slide
    
    Args:
        prs: Presentation object
        layouts: Layout dictionary
        title: Slide title
        left_header: Left column header
        left_bullets: List of bullets for left
        right_header: Right column header  
        right_bullets: List of bullets for right
    """
    slide = prs.slides.add_slide(layouts['two_column'])
    
    # Set title with NO FILL, NO BORDER
    title_shape = slide.shapes.title
    title_shape.text = title
    format_title_no_fill(title_shape)
    title_shape.text_frame.paragraphs[0].font.size = Pt(36)
    title_shape.text_frame.paragraphs[0].font.color.rgb = VM_RED
    title_shape.text_frame.paragraphs[0].font.bold = True
    
    # Find content placeholders
    placeholders = [s for s in slide.placeholders 
                   if s.placeholder_format.type == 7]  # OBJECT type
    
    if len(placeholders) >= 2:
        # Left column
        left_tf = placeholders[0].text_frame
        left_tf.clear()
        p = left_tf.paragraphs[0]
        p.text = left_header
        p.font.bold = True
        p.font.size = Pt(24)
        p.font.color.rgb = VM_RED
        
        for bullet in left_bullets:
            p = left_tf.add_paragraph()
            p.text = bullet
            p.font.size = Pt(18)
            p.font.color.rgb = VM_DARK_GRAY
        
        # Right column
        right_tf = placeholders[1].text_frame
        right_tf.clear()
        p = right_tf.paragraphs[0]
        p.text = right_header
        p.font.bold = True
        p.font.size = Pt(24)
        p.font.color.rgb = VM_RED
        
        for bullet in right_bullets:
            p = right_tf.add_paragraph()
            p.text = bullet
            p.font.size = Pt(18)
            p.font.color.rgb = VM_DARK_GRAY
    
    return slide
```

#### Section Divider Slide

```python
def add_section_divider(prs, layouts, section_title, subtitle=None):
    """
    Add section divider slide (typically for Appendix)
    
    Args:
        prs: Presentation object
        layouts: Layout dictionary
        section_title: Section name
        subtitle: Optional subtitle
    """
    slide = prs.slides.add_slide(layouts['section_red'])
    
    title_shape = slide.shapes.title
    title_shape.text = section_title
    title_shape.text_frame.paragraphs[0].font.size = Pt(54)
    title_shape.text_frame.paragraphs[0].font.bold = True
    title_shape.text_frame.paragraphs[0].font.color.rgb = VM_WHITE
    
    if subtitle:
        for shape in slide.placeholders:
            if shape.placeholder_format.type == 4:  # SUBTITLE
                shape.text = subtitle
                shape.text_frame.paragraphs[0].font.size = Pt(32)
                shape.text_frame.paragraphs[0].font.color.rgb = VM_WHITE
                break
    
    return slide
```

#### Diagram Slide

```python
def add_diagram_slide(prs, layouts, title, image_path=None):
    """
    Add slide for architecture diagram
    
    Args:
        prs: Presentation object
        layouts: Layout dictionary
        title: Slide title
        image_path: Path to diagram image (PNG/JPG), or None for placeholder
    """
    slide = prs.slides.add_slide(layouts['title_only'])
    
    # Set title with NO FILL, NO BORDER
    title_shape = slide.shapes.title
    title_shape.text = title
    format_title_no_fill(title_shape)
    title_shape.text_frame.paragraphs[0].font.size = Pt(36)
    title_shape.text_frame.paragraphs[0].font.color.rgb = VM_RED
    title_shape.text_frame.paragraphs[0].font.bold = True
    
    if image_path and os.path.exists(image_path):
        # Add image centered on slide
        left = Inches(1.5)
        top = Inches(2)
        width = Inches(10)
        slide.shapes.add_picture(image_path, left, top, width=width)
    else:
        # Add placeholder text for diagram
        left = Inches(2)
        top = Inches(2.5)
        width = Inches(9.5)
        height = Inches(4)
        
        textbox = slide.shapes.add_textbox(left, top, width, height)
        tf = textbox.text_frame
        tf.text = "[Insert Architecture Diagram Here]\n\nKey Components:\n• Component 1\n• Component 2\n• Component 3\n\nIntegrations:\n• System A → System B\n• System C → System D"
        
        p = tf.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER
        p.font.size = Pt(20)
        p.font.color.rgb = VM_MEDIUM_GRAY
    
    return slide
```

### Complete Workflow Function

```python
def build_executive_presentation(content_dict, output_filename):
    """
    Build complete executive presentation from structured content
    
    Args:
        content_dict: Dictionary with all presentation content (see example below)
        output_filename: Name for output file (without .pptx extension)
        
    Returns:
        output_path: Path to saved presentation
    """
    
    # Create presentation from template
    prs, layouts = create_presentation()
    
    # 1. Cover Slide
    add_cover_slide(
        prs, layouts,
        content_dict['title'],
        content_dict['subtitle']
    )
    
    # 2. Executive Summary
    add_executive_summary(
        prs, layouts,
        content_dict['exec_summary']['situation'],
        content_dict['exec_summary']['challenge'],
        content_dict['exec_summary']['recommendation'],
        content_dict['exec_summary']['business_impact'],
        content_dict['exec_summary']['investment'],
        content_dict['exec_summary']['key_risk']
    )
    
    # 3. Current State
    add_content_slide(
        prs, layouts,
        "Current State Challenges",
        content_dict['current_state']
    )
    
    # 4. Proposed Solution
    add_content_slide(
        prs, layouts,
        "Proposed Solution",
        content_dict['solution']
    )
    
    # 5. Architecture Diagram
    diagram_path = content_dict.get('architecture_diagram_path')
    add_diagram_slide(
        prs, layouts,
        "Solution Architecture",
        diagram_path
    )
    
    # 6. Implementation Roadmap
    if len(content_dict['implementation_phases']) == 2:
        phases = content_dict['implementation_phases']
        add_two_column_slide(
            prs, layouts,
            "Implementation Roadmap",
            phases[0]['title'],
            phases[0]['bullets'],
            phases[1]['title'],
            phases[1]['bullets']
        )
    else:
        # For 3 phases or single phase, use bullet slide
        roadmap_bullets = []
        for phase in content_dict['implementation_phases']:
            roadmap_bullets.append((phase['title'], phase['bullets']))
        add_content_slide(prs, layouts, "Implementation Roadmap", roadmap_bullets)
    
    # 7. Business Benefits
    add_content_slide(
        prs, layouts,
        "Business Benefits",
        content_dict['benefits']
    )
    
    # 8. Investment & Resources
    add_two_column_slide(
        prs, layouts,
        "Investment Required",
        "Financial Investment",
        content_dict['investment']['financial'],
        "Resource Requirements",
        content_dict['investment']['resources']
    )
    
    # 9. Risks & Mitigation
    add_content_slide(
        prs, layouts,
        "Key Risks & Mitigation Strategies",
        content_dict['risks'],
        use_red_background=True
    )
    
    # 10. Recommendations
    add_content_slide(
        prs, layouts,
        "Recommendations & Next Steps",
        content_dict['recommendations'],
        use_red_background=True
    )
    
    # 11. Appendix Divider
    add_section_divider(
        prs, layouts,
        "Appendix",
        "Supporting Details & Technical Information"
    )
    
    # 12+. Appendix Slides
    if 'appendix' in content_dict:
        for app_slide in content_dict['appendix']:
            add_content_slide(
                prs, layouts,
                app_slide['title'],
                app_slide['content']
            )
    
    # Save presentation
    if not output_filename.endswith('.pptx'):
        output_filename += '.pptx'
    
    output_path = f'/mnt/user-data/outputs/{output_filename}'
    prs.save(output_path)
    
    return output_path
```

### Save and Present

```python
# After building presentation:
output_path = build_executive_presentation(content_dict, 'My_Presentation')

# Present to user
print(f"Presentation created successfully: {output_path}")
```

## Content Dictionary Structure

When processing user input, structure it as:

```python
content_dict = {
    'title': "Main Presentation Title",
    'subtitle': "Context or Department",
    
    'exec_summary': {
        'situation': "Current state in 1 sentence",
        'challenge': "Problem in 1 sentence",
        'recommendation': "Solution in 1 sentence",
        'business_impact': [
            "Quantified benefit 1",
            "Quantified benefit 2",
            "Quantified benefit 3"
        ],
        'investment': "€X.XM investment, X-month timeline",
        'key_risk': "Top risk - Mitigation: strategy"
    },
    
    'current_state': [
        "Challenge 1 with specific metrics",
        "Challenge 2 with quantified impact",
        "Challenge 3 with data"
    ],
    
    'solution': [
        "Solution component 1",
        "Solution component 2",
        "Solution component 3"
    ],
    
    'architecture_diagram_path': None,  # or "/path/to/diagram.png"
    
    'implementation_phases': [
        {
            'title': "Phase 1: Name (Timeline)",
            'bullets': [
                "Deliverable 1",
                "Deliverable 2",
                "Deliverable 3"
            ]
        },
        {
            'title': "Phase 2: Name (Timeline)",
            'bullets': [
                "Deliverable 1",
                "Deliverable 2"
            ]
        }
    ],
    
    'benefits': [
        "Benefit 1 with numbers",
        "Benefit 2 with percentages",
        "Benefit 3 with savings"
    ],
    
    'investment': {
        'financial': [
            "Cost item 1: €XXK",
            "Cost item 2: €XXK",
            "Total: €X.XM"
        ],
        'resources': [
            "Resource need 1",
            "Resource need 2",
            "Ongoing support model"
        ]
    },
    
    'risks': [
        "Risk 1 (IMPACT): Description - Mitigation: Strategy",
        "Risk 2 (IMPACT): Description - Mitigation: Strategy"
    ],
    
    'recommendations': [
        "Recommended decision: [Specific approval]",
        "Decision timeline: [When and why]",
        "Next steps:",
        ("", [
            "Action 1 - Owner (Date)",
            "Action 2 - Owner (Date)"
        ])
    ],
    
    'appendix': [
        {
            'title': "Detailed Cost Breakdown",
            'content': ["Detail 1", "Detail 2"]
        },
        {
            'title': "Technical Specifications",
            'content': ["Spec 1", "Spec 2"]
        }
    ]
}
```

## Processing User Input

### Step 1: Analyze Requirements

When user provides plain text, extract:
- Topic/subject matter
- Key problem or challenge
- Proposed solution
- Business benefits/impacts
- Costs and timeline
- Risks mentioned
- Decision needed

### Step 2: Enhance and Quantify

Transform vague statements:
- "Save money" → "Reduce costs by 30% (€2.1M annually)"
- "Faster" → "Deploy in 2 weeks vs. 6 months (12x faster)"
- "Better security" → "Achieve SOC 2 compliance, reduce vulnerabilities by 85%"

### Step 3: Structure Content

Map user input to content_dict structure, filling in:
- Executive summary components
- Problem bullets with metrics
- Solution benefits quantified
- Phased implementation plan
- Financial and resource requirements
- Risks with mitigation strategies
- Clear recommendations

### Step 4: Generate Presentation

Call `build_executive_presentation()` with structured content.

## Quality Checklist

Before finalizing:

### Branding
- [ ] Cover slide has Virgin Media logo centered
- [ ] All content slides have footer (VM logo | LG logo | CTIO | page #)
- [ ] Virgin Media Red used for titles and emphasis
- [ ] **Titles have NO FILL and NO BORDER** (critical!)
- [ ] Color scheme is consistent

### Content
- [ ] Every slide passes 5-second test
- [ ] All numbers are specific and quantified
- [ ] Technical jargon translated to business language
- [ ] Risks identified with mitigation
- [ ] Clear recommendation with next steps

### Structure
- [ ] Follows mandatory slide sequence
- [ ] Maximum 15-20 main slides (before appendix)
- [ ] Appendix for technical details
- [ ] Logical flow: Problem → Solution → Action

### Visual
- [ ] All text readable (minimum 18pt body)
- [ ] Maximum 6 bullets per slide
- [ ] Diagrams have labels and legends
- [ ] Professional, uncluttered appearance

### Executive Readiness
- [ ] Can be presented in 20-30 minutes
- [ ] Key messages in first 5 slides
- [ ] Decision point is clear
- [ ] Business case is compelling

## Tips for Excellence

1. **Less is More**: Remove slides that don't support the decision
2. **Numbers Tell Stories**: Quantify every claim possible
3. **Show, Don't Just Tell**: Use diagrams for complex concepts
4. **Anticipate Questions**: Prepare appendix for deep dives
5. **Practice Timing**: 2-3 minutes per slide maximum
6. **Get Feedback**: Show drafts to stakeholders early
7. **Know Your Audience**: Adjust technical depth
8. **Surface Risks Proactively**: Executives trust honest architects
9. **Brand Consistency**: Follow VMIE guidelines religiously
10. **End with Action**: Clear next steps and ownership

## Common Presentation Types

### Cloud Migration
- Current infrastructure costs vs. cloud TCO
- Migration waves and business continuity
- Security and compliance in cloud
- Training and change management

### System Integration
- Current integration spaghetti diagram
- Target hub-and-spoke or API-led architecture  
- Data consistency and process automation benefits
- Phased integration delivery

### Security/Compliance
- Regulatory requirements and current gaps
- Risk assessment with quantified exposure
- Remediation roadmap prioritized by risk
- Cost of compliance vs. cost of breach

### Network Architecture
- Current network topology and bottlenecks
- Proposed SD-WAN or network modernization
- Performance improvements (latency, throughput)
- Redundancy and disaster recovery

## Final Note

The goal is not to impress with technical knowledge, but to make executives **confident in their decision** by providing clear, concise, actionable information with proper Virgin Media branding.

Great presentations are:
- ✅ Clear and concise
- ✅ Business-focused with quantified benefits
- ✅ Honest about risks
- ✅ Actionable with specific next steps
- ✅ Professionally branded (VM + LG)
- ✅ Visually clean with NO FILL/NO BORDER titles

Follow this skill for presentations that consistently drive results.

---

*End of SKILL.md*