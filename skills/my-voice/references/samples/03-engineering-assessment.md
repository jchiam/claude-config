<!-- Genre: assessment + proposal. Self-authored; sanitised (entities, figures and domain replaced with neutral placeholders) and proof-read. Appendix omitted. -->

# Context

## Background

Since its commissioning, Platform X has evolved significantly from a single-purpose system to a nationwide platform. While this transformation has been successful in terms of feature delivery, the rapid evolution has led to several critical engineering challenges:

- Complex codebase resulting from extensive code modifications and unnatural enhancements that required substantial restructuring of existing code or database structure
- Extensive vendor internal testing cycles (10-12 weeks of regression testing) to ensure quality issues are addressed before release, indicating fundamental gaps in engineering practices
- Heavy reliance on in-house manpower for UAT to identify bugs missed by the vendor, suggesting inefficiencies in the quality assurance process
- Accumulation of technical debt due to prioritising feature delivery over code quality, coupled with quick-fix modifications mindset to save cost rather than looking at sustainable long-term solutions

## Key Challenges

These historical practices have resulted in systemic issues that now impact the platform's sustainability and future development:

- A waterfall-like delivery cycle despite adopting agile methodology, leading to lengthy multi-month production deployment cycles
- Compromised engineering practices and quality standards due to the current team structure and fully outsourced contractual model
- Growing technical debt that increasingly affects system stability and feature development
- Complex code base and design that's becoming increasingly difficult to maintain (several hundred thousand lines of code), raising concerns about escalating costs for future changes and long-term maintainability

# Product Team Structure (Engineering)

While it would be beneficial to evaluate the product team structure holistically, this writeup primarily focuses on the engineering aspects of the team structure, with minor references to the team circumstance in product and design disciplines where necessary to better describe the state of engineering in Platform X.

## Key Observations

The vendor team structure (Appendix 1) is split into a few functions. There is a distinct ops team, led by a tech lead and ops project manager. The rest are part of the development team, consisting of squads and functions that deliver features (Sprint Delivery Track), support testing (Regression Track), urgent fixes (Rapid Fix Track), Quality Assurance (QA) and tech specialists (SA and Tech Leads).

Some notable points:

- The tech specialists, comprising the Solution Architect (SA) and Tech Leads (TLs), primarily exist to work with the product lead on high level technical direction and initiatives. The Tech Leads are senior Software Engineers (SWEs) who have better technical skills and deep technical knowledge of the platform, but are not primarily involved in its delivery on a day-to-day basis.
- The team, as at writing, redeployed 2 TLs as Scrum Masters (SM), functioning as the bridge between business requirements and managing of the sprint delivery squads. The SMs are more akin to technical Business Analysts (BAs) than SMs.

### Observation 1 - Project team lacked cross-functional representation

In a product as major as Platform X, concerns that go beyond delivering immediate business value should be given sufficient consideration in the product development process. The current setup where delivery decisions mostly involved business and the vendor, brokered through the SMs, makes it challenging for Digital Office (DO) personnel to systematically influence the team to uphold engineering and design excellence. For example, the problems of the current engineering team structure, while apparent to DO, may not be of equal concern to business. Technical concerns tend to be underappreciated due to lack of expertise of the business, thus emphasising the importance of having sufficient cross-functional representation.

### Observation 2 - Gaps in tech leadership

The current team structure creates a void in tech leadership. While there were attempts at working through the vendor SA and TLs, any effort in ensuring engineering excellence would be challenging, given the scale and structure of the team. When developers report to vendor SMs, delivery of features would more likely be prioritised simplistically over proper investment in technical strategies and tech debt management. Tactically, the drive towards engineering excellence can start with top-down mandates, but must ultimately be executed on the ground. As such, related to Observation 1, technical leadership needs to be present at all levels of the development team.

### Observation 3 - Lacked DevOps culture

The engineering team structure represented the traditional throw-over-the-wall model, an anti-pattern to cross-functional teams. Developers in the Sprint Delivery Track build fast, QAs had to keep up and call out quality gaps left by the delivery track. Ops just run ops, while throwing production issues back to the development team. The Rapid Fix Track was present to quickly fix issues, but solutions tended to be superficial, leading to more tech debt in the long run. There was no shared ownership on delivery and quality of the product. This manifested itself in knowledge gaps across the functions, and "it's their problem" mindset. Product quality ultimately suffered.

# Proposal

The following drivers in the proposal adopt certain product development principles that have been proven to work in similar modernisation projects. While actual conditions could be different, the fundamental aspects of what makes a successful, impactful engineering (and product) team should be largely similar.

- Shared ownership of the product at all levels of the project
- Strong cross-functional mindset and team structure
- Empowered engineering leadership from DO

## Key Drivers

### Driver 1 - Shared ownership between Business Division and DO

To support cross-functional collaboration in Platform X, shared ownership of the product between the Business Division (BD) and DO is essential. While BD plays a key role in addressing current business needs, the quality of design and engineering significantly influences the long-term sustainability and adaptability of the product. Recognising the importance of balancing feature delivery with technical improvements will help ensure that the platform remains resilient and responsive to future demands.

### Driver 2 - Shift from outsource to co-source

Related to Observation 2, a co-source model would be preferred to safeguard the strategic interests of DO in this proposal. We need capable in-house engineers who can be part of the development squads to ensure technical leadership, not just from the top, but also at the working level.

### Driver 3 - Establish best practices in software engineering

Building on top of the Shift Left initiative started by the team earlier in the year, more could be done to address Observations 2 and 3. This needs to be a medium to long term investment that addresses changing mindsets, and reinventing the existing engineering team structure in order to build a sustainable, high performing engineering team.

Key focus areas include:

- Establish sound engineering leadership, explore roles of Engineering Managers and Tech Leads.
- Inculcate DevOps mindset, establish best practices and restructure the engineering team around DevOps

## Actionables for Consideration

### Identify tactical opportunities to POC new team setup and ways of working

Ideally, we would want to start small and POC on a vertical slice of the platform, executing development and delivery end-to-end. Examples of tactical opportunities are:

- A vertical in the platform is due for revamp
- System architecture or capabilities in need of refresh

Tying the POC up with product goals presents good tactical opportunities for the product and team to transit.

### Re-establish partnership between DO, BD and the vendor

The proposal would require all parties, especially BD, to be on board with the long-term direction of the product team, and a review of the partnership with the vendor.

### Bring in the right resources for the POC

Start by forming a small squad for the POC, led by in-house capabilities. Augmentation by industry partners is possible as well.
