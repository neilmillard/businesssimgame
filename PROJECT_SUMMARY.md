# Business Simulation Game - Project Summary

## Project Overview

This is a business simulation game built using Godot 4.5+ and Maaack's Game Template. The game teaches players business management skills through an interactive simulation where they manage marketing campaigns, sales processes, product development, and financial operations to grow a successful business.

## Game Architecture

### Core Business Departments

The game is structured around four main business departments, each implemented as separate resource classes:

#### 1. Finance Department (`scripts/finance.gd`)
- **Purpose**: Complete financial management system for the business
- **Key Features**:
  - Cash balance tracking (starts with $50,000)
  - Revenue and expense categorization
  - Assets management (inventory, equipment, intellectual property)
  - Liabilities tracking (debt, accounts payable)
  - Financial health indicators and profit/loss calculations
  - Balance sheet and P&L report generation
- **Metrics Tracked**: Net profit, gross margin, total assets, equity

#### 2. Marketing Department (`scripts/marketing.gd`)
- **Purpose**: Lead generation and brand awareness management
- **Key Features**:
  - Campaign management system with three types:
    - AWARENESS: Targets oblivious buyers to educate them
    - INTEREST: Converts educated buyers to interested prospects
    - MIXED: Targets both audience segments
  - Team skill levels and content quality tracking
  - Budget management and campaign effectiveness calculations
  - Brand awareness and performance metrics
- **Campaign Attributes**: Duration, cost, effectiveness, target audience size
- **Metrics Tracked**: Buyers reached, leads generated, campaign ROI

#### 3. Sales Department (`scripts/sales.gd`)
- **Purpose**: Lead qualification and conversion to revenue
- **Key Features**:
  - Complete sales funnel management (contact → qualify → convert)
  - Lead processing with qualification standards
  - Conversion rate tracking and team effectiveness
  - Product matching algorithms for optimal sales
  - Sales cycle timing and follow-up management
- **Lead Stages**: Fresh → Contacted → Qualified → Converted/Lost
- **Metrics Tracked**: Conversion rates, sales revenue, cycle times

#### 4. Operations Department (`scripts/operations.gd`)
- **Purpose**: Product development and operational management
- **Integration**: Works with other departments for product lifecycle management

### Game Entities

#### Product System (`scripts/product.gd`)
- **Comprehensive Attributes**:
  - Core metrics: Attractiveness, utility, cost, retail price, value
  - Quality indicators: Build quality, durability, brand appeal
  - Market positioning: Market fit, innovation level, environmental impact
- **Business Logic**:
  - Profit margin calculations
  - Market demand estimation with price sensitivity
  - Development cost modeling based on complexity and innovation
  - Market readiness assessment
- **Scoring System**: Weighted overall product score for decision-making

#### Buyer System (`scripts/buyer.gd`)
- **Purpose**: Represents market demand and customer behavior
- **Integration**: Interacts with marketing campaigns and sales processes
- **Behavior**: Different buyer states (oblivious, educated, interested)

#### Lead Management (`scripts/lead.gd`)
- **Purpose**: Tracks potential customers through the sales funnel
- **Features**: Lead quality scoring, status tracking, conversion probability

### Game State Management

#### Level System (`scenes/game_scene/levels/`)
- **Structure**: 3 progressive levels (level_1.tscn, level_2.tscn, level_3.tscn)
- **Core Logic** (`level.gd`):
  - Integrates all business departments
  - Manages game time and progression
  - Handles tutorial system
  - Tracks level-specific objectives and win/lose conditions
  - Provides GUI updates and player feedback

#### State Persistence (`scripts/game_state.gd`, `scripts/level_state.gd`)
- **Features**:
  - Save/load game progress
  - Level-specific state management
  - Tutorial completion tracking
  - Player customization (background colors)

## Game Flow and Mechanics

### Business Simulation Loop
1. **Product Development**: Create products with various attributes affecting market success
2. **Marketing Campaigns**: Launch targeted campaigns to generate awareness and leads
3. **Sales Process**: Contact, qualify, and convert leads to actual sales
4. **Financial Management**: Track cash flow, expenses, and profitability
5. **Strategic Decisions**: Balance investments across departments for optimal growth

### Progression System
- **3-Level Structure**: Each level presents increasing complexity and challenges
- **Tutorial Integration**: Built-in tutorial system for onboarding
- **Win/Lose Conditions**: Level-specific objectives for advancement
- **Persistent Progress**: Save system maintains player advancement

### Key Game Mechanics
- **Resource Management**: Limited budget requires strategic allocation
- **Market Dynamics**: Buyer behavior responds to marketing and product quality
- **Risk/Reward**: Investment decisions impact long-term business success
- **Performance Tracking**: Comprehensive metrics across all departments

## Technical Implementation

### Framework
- **Engine**: Godot 4.5+ (4.3+ compatible)
- **Template**: Built on Maaack's Game Template for professional menu systems
- **Architecture**: Resource-based system for easy save/load and data management

### Project Structure
```
scripts/
├── Core Business Classes
│   ├── finance.gd - Financial management
│   ├── marketing.gd - Campaign and lead generation
│   ├── sales.gd - Lead conversion and sales tracking
│   └── operations.gd - Product development operations
├── Game Entities
│   ├── product.gd - Product attributes and calculations
│   ├── buyer.gd - Customer behavior simulation
│   └── lead.gd - Sales prospect management
└── Game State
    ├── game_state.gd - Global state management
    ├── level_state.gd - Level-specific persistence
    └── level_and_state_manager.gd - State coordination

scenes/game_scene/levels/
├── level.gd - Main level controller
├── level_1.tscn - Tutorial/beginner level
├── level_2.tscn - Intermediate challenges
└── level_3.tscn - Advanced business scenarios
```

### Key Features
- **Modular Design**: Each department operates independently but integrates seamlessly
- **Realistic Business Logic**: Authentic financial calculations and market dynamics
- **Scalable Architecture**: Easy to add new departments or mechanics
- **Educational Value**: Teaches real business concepts through gameplay

## Target Audience
- **Primary**: Students and professionals interested in business education
- **Secondary**: Strategy game enthusiasts and simulation game players
- **Educational Use**: Business schools, entrepreneurship programs, corporate training

## Development Status
- **Core Systems**: Fully implemented with comprehensive business logic
- **Levels**: 3 levels with progressive difficulty
- **UI/UX**: Professional menu system via Maaack's template
- **Save System**: Persistent progress and customization
- **Tutorial System**: Integrated onboarding for new players

This business simulation game provides a comprehensive and realistic business management experience, teaching players essential skills in marketing, sales, finance, and operations through engaging gameplay mechanics.