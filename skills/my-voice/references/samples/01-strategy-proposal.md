<!-- Genre: strategy proposal. Self-authored; sanitised (entities, dates and domain replaced with neutral placeholders) and proof-read. -->

# Context

As at writing, Platform A has an established development roadmap for the mainstream modules, mainly Module B and Module C, with guidance and alignment from management that they should be the top priorities of the team. However, the plans for Non-Core Modules (NCM), outlined red in the roadmap diagram below, were unclear.

During the Feb Steering Committee (SC), management requested for the team to propose the next steps for the development of NCM, given that the original plan stated starting development in Q3. The team proposed to provide an answer by the Oct SC.

Roadmap caa 240301, NCM are outlined in red

## Considerations

The existing division resources, including the ARs hired organically, are fully stretched across the different workstreams in support and development of the mainstream modules, namely Module A, Module B and Module C. Spawning another workstream for NCM will impact the delivery of Module C. It would also be challenging to scale the team up further via ARs as the tech leads are also fully stretched given the existing team composition. More ARs to manage will increase the cognitive burdens of the existing engineering, design and product leadership offered by the division, which may negatively impact the delivery and quality of the mainstream modules.

# Intended Outcomes

Regardless of approaches, we want to ensure that the Platform A team succeeds in the delivery of NCM, with reasonable quality and within reasonable timeline. This could mean the core engineering team will still have to support, to a reasonable extent, in areas such as hiring of the NCM squad, onboarding of the squad to our tooling and resources and provide some level of consultancy.

The success of Platform A is the only way for the division to have ultimately left a positive (digital transformation) impact in this domain and be able to exit in due time.

# Approach

Jointly between the division and the Business Owner (BO), the team proposed to form an augmented agile squad that is independent of the existing engineering team. This team will be managed directly by the BO, through IT and process governance and less of direct engineering leadership from the division. The team must leverage on the established building blocks laid out by the existing team e.g. tech stack, design system, cloud infra, CI/CD as part of the baseline set of software development governance laid out by engineering. The BO and the policy team will jointly govern via processes and outcomes, similar to how outsourced projects fundamentally work.

The building blocks will continue to be developed, maintained and governed by the division in the meantime, until they are ready for handover in future.

## Strategic Benefits

There are strategic benefits to the approach, aside from the baseline requirements to not distract the main engineering team from the top development priority for Module C.

- NCM is a relatively small sandboxed development space if it is developed based on existing building blocks, coupled with the hypothesis that there will be a lot of reuse from Module B features.
- Development by a separate squad could be a good test bed of the usability and completeness of the existing building blocks.
- Setting up an independent squad without complete and direct involvement from the division could be a good experiment on the ways of working in preparation of the division's exit in future.

## Prerequisites

- Building blocks must be well-documented and accessible to the NCM squad.
- Guardrails must be present such that the NCM squad would not be able to mess with key components of Platform A e.g. building blocks, core infra, non-NCM deployments
