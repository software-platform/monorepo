# Feature design
> Feature description / User story.

## Contents

In this section, provide the contents for the document including all custom subsections created.

- [**Analysis**](#analysis)
    - [Feasibility study](#feasibility-study)
    - [Requirements](#requirements)
    - [Landscape](#landscape)
    - [Prototyping](#prototyping)
    - [System modeling](#system-modeling)
- [**Design**](#design)
    - [Architecture](#architecture)
    - [User Interface](#user-interface)
    - [Database](#database)
    - [Privacy](#privacy)
    - [Security](#security)
    - [Program](#program)

# Analysis
> Describe a general analysis approach.

In this section, describe the methodology to feature analysis, possible solutions, and areas that need to be explored, ways to compare alternatives. It should be a brief plan for all sub-sections.

_**Important Note**: Avoid excessive details in the Analysis subsections. Think about the feature at the very top-level abstraction. Provide the details only where necessary (e.g. in the [Prototyping](#prototyping) section)._

### Feasibility study
> A preliminary study of the feasibility of implementing this feature.

One should answer the following:

- How this feature would help end-users and would they use it?
- Does this feature meet the project's scope?
- Does this feature fit the project's purpose?

### Requirements
> Define requirements and make sure that they are complete.

This section should cover the requirements of the feature. One should follow the next guide tips working on this section:

- list all the requirements for the feature in details;
- make sure the requirements are clear and complete;
- think about edge cases and if there are missing requirements;
- clarify the requirements by answering possible questions (_What if ...?_).

The described requirements should become acceptance criteria for the feature and its parts under development.

### Landscape
> Look for existing solutions in the area.

In this section, one should select the general implementation approach for the feature under analysis. The purpose is to answer the question: **"Is this going to be a custom solution or the existing one is to be used?"**.

One should review the existing solutions in the area and capture all relevant references, snippets, excerpts that would help to make an informed decision.

The general algorithm in this section is following:

1. List the existing packages/solutions/approaches for the feature.
2. List the pros & cons of each solution. This step may be optional if the solution is preliminary custom.
3. Select the solution (or conclude the solution is custom) and explain your choice.

_**Note**: The implementing approach shouldn't be a diagram, algorithm, etc. This should be a top-level approach to implement the desired feature. The selected approach must state whether the implementation should be custom or use the existing solution (e.g. package, library), or improve the existing solution to fit requirements._

### Prototyping
> Create a simple prototype to confirm that implementing this feature is possible.

Using the selected approach, one should provide prototypes for all high-risk requirements. High-risk means the ones that we are not sure that it's possible to implement in a reasonable time frame while applying best practices.

Generally speaking, in the [Feasibility study](#feasibility-study) and [Landscape](#landscape) section, one states the solution is possible. In this section, one should prove this statement with prototypes and provide profs in a form of code snippets/sample application.

_**Note**: Prototypes must cover the possible problems and edge cases for the feature, and exemplify how to solve them. There is no need to deep dive into such cases - the [Design](#design) section should discover details. Instead, prototypes should expose that the selected approach provides a convenient way to handle edge cases._

### System modeling
> Create an abstract model of the system/feature.

The purpose of this section is to discover the relation of the new feature to the existing project's implementations. In general, the section should examine the feature's place in the project's world. To archive this goal, one should consider the existing components/modules of the project and think of the feature as such. Then, answer the following:

- Is the new feature a part of the existing component? Does it complement or improve/upgrade this component?
- Is the new feature should be a part of a standalone component? How this component is going to interact with other components?

The above questions are focused on one purpose: the place and role of the new feature. To simplify reasoning, one may use the component or other diagrams in this section.

# Design

The design section purposes discovering the implementation details for the feature. What is the structure of the feature? How is the feature to be integrated into the project/component(s)? And many other details are covered by the subsections below. But before we dive into explanations for the design parts, one should consider the following rules that hold for the whole design section:

- The design acts within the requirements examined in the [Requirements](#requirements) section.
- The design details all the [Analysis]($analysis) section describes/touches.
- The design's subsections must not leave open questions about the selected implementation approach. Each section ends with clear and definitive details about exactly one implementation approach.

### Architecture
> Fundamental structures of the feature and context (diagram).

This section examines the overall, top-level architecture of the feature. This architecture defines the approach to the feature implementation discussed in more detail in the next section. The following points hold for the section:

- The section provides and examines the fundamental architecture of the feature with no details (classes, methods, etc.).
- The section explains the implementation approach to the feature. If there are several implementation approaches:
    - the section examines each approach and reviews its pros and cons;
    - the section selects one approach and explains the choice providing clear reasoning.
- The section represents the architecture with the components diagram demonstrating responsibilities and the overall algorithm.

### User Interface
> How users will interact with the feature (API, CLI, Graphical interface, etc.).

In this section, one should explain how users interact with the feature. The important note here is that a user is an abstraction that represents an interaction participant. These could be an end-user, developer, another component, etc. The general purpose is to describe the usage of the feature.

Consider the following examples:

- If the feature is related to the CLI tool, the usage can be described as the feature command executing example or the `help` command output that includes the feature-related points.
- If the feature is related to the web application, the usage can be described as the User Interface [wireframes](https://plantuml.com/en/salt).
- If the feature is related to the core implementation, the usage can be represented as the feature integration steps or the feature component usage within another component.

### Database
> How relevant data will be persisted and protected.

This section covers all the data persisting the feature implies. If the feature does not involve storing the user's data, one should state this fact and proceed to the next section.

One should consider the following working on this section:

- Describe data the feature would persist in detail (data structure, storing format, etc.).
- Describe the data storage (a database, DBMS, etc.):
    - If the data storage is defined by the project-specific storage, one may omit the details.
    - If there are several possible storages the feature can use, one should review options with their pros and cons and select the one storage to use.
- Describe how the feature is to interact with the storage (e.g., CRUD operations, possible scopes, queries).
- Describe the limitations, quotes, if there are any that make sense for the feature.

### Privacy
> Privacy by design. Explain how privacy is protected (GDPR, CCPA, HIPAA, etc.).

This section discovers how users' privacy is protected. One should cover the following points:

- Describe what user's data is collected and how this data is protected. These may refer to analytics sent to 3rd-party services, cookies, etc.
- Define privacy regulations the feature or related component act according to (GDPR, CCPA, HIPAA, etc.).
- Describe a possibility of disabling data collecting in the scope of the feature.

### Security
> How relevant data will be secured (Data encryption at rest, etc.).

The Security section purposes describing how users' data is secured. This is related to all data that users provide, and the application then stores in the [Database](#database) or using 3rd-party services. This section should contain the following information:

- how data is secured from insufficient access;
- how a user can gain an access to their data (authentication/authorization, user's scope, etc.);
- how data is encrypted and what exactly the stored information is encrypted (consider the same data described in both [Database](#database) and [Privacy](#privacy) sections).

To provide a full security review, one should consider performing the [threat modeling](https://en.wikipedia.org/wiki/Threat_model). This section may use the existing threat model or create and use a new one.

### Program
> Detailed solution description to class/method level.

In this section, one should dive into implementation details and solidify the feature architecture. One should consider visualizing all the given information, if possible, to simplify the understanding of how the feature is working. To archive the great and clear visualization, the classes/sequence/activity/etc. diagrams may be used along with the tables and lists. The general idea is to clearly define the feature architecture design.

One should keep the following guide:

- Describe the feature structure as precisely as possible with classes, their methods, and fields (this should match the described abstractions in the [Architecture](#architecture) section).
- Describe all classes and their responsibilities.
- Describe changes in the existing classes, if any.
- Provide code snippets to clarify complex parts in the feature implementation (these snippets are to be short and not reveal the context they belong to - as short as possible to demonstrate the idea).

### Testing
> Describe an approach on how the feature should be tested.

This section concerns the feature testing process. Depending on the implementation, one should state what tests the feature implies, for example: 

- unit tests;
- mockito tests;
- integration tests;
- e2e tests;
- etc.

Also, the section should cover the feature testing challenges. More precisely, this means that if the feature testing is not obvious, one should consider describing the most complex test cases.
