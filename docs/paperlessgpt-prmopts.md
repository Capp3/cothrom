# Prompts

## Correspondent Prompt

```md
I will provide you with the content of a document. Your task is to suggest the single most relevant correspondent for that document.

A correspondent is the person, company, institution, manufacturer, standards body, broadcaster, supplier, vendor, service provider, or organization that the document originates from or is addressed to.

In Paperless-ngx, correspondents are used to organize and retrieve documents efficiently.
Choose the real-world entity most responsible for issuing, publishing, sending, or receiving the document.

For this document set, many files are technical papers, manuals, specification sheets, engineering documents, compliance records, product literature, and broadcast-industry reference material.
These documents often do not name a clear individual author.
In such cases, prefer the manufacturer, publisher, brand owner, standards body, broadcaster, or issuing organization rather than a person.

Respond only with a single correspondent name, without any additional text.

Important constraints:
- Prefer an exact or normalized match from <example_correspondents> where possible.
- Never return a name that appears in <blacklisted_correspondents>.
- Return only one correspondent.
- Do not explain your reasoning.
- Do not include punctuation, quotes, labels, or extra words.
- If no suitable correspondent can be identified with reasonable confidence, respond with "Unknown".

Normalization rules:
- Prefer simple, well-known organization names.
- Avoid legal or financial suffixes such as "Ltd", "Limited", "GmbH", "AG", "B.V.", "Inc.", "LLC", or similar, unless the shorter name would become ambiguous.
- Prefer "Microsoft" instead of "Microsoft Ireland Operations Limited".
- Prefer "Amazon" instead of "Amazon EU S.a.r.l.".
- Prefer "Sony" instead of "Sony Europe B.V.".
- Prefer "BBC" instead of "British Broadcasting Corporation", if that is the normalized form already used in <example_correspondents>.

How to choose the correspondent, in order of priority:
1. Choose the document issuer named in the header, footer, cover page, title page, masthead, copyright notice, publisher line, company address, signature block, website domain, or email domain.
2. For technical documents, prefer the manufacturer, product brand owner, or publishing organization even when no person is named.
3. For manuals, datasheets, brochures, application notes, white papers, installation guides, engineering drawings, and workflow documents, prefer the company or standards body that published the document.
4. For invoices, statements, certificates, notices, letters, and emails, prefer the sender unless the document is clearly outbound from us to a recipient.
5. For outbound correspondence clearly created by us, prefer the recipient if clearly identifiable.
6. For standards, recommendations, technical specifications, or governance documents, prefer the standards or governing body that issued the document.
7. If both a reseller/integrator and an OEM/manufacturer appear, prefer the OEM/manufacturer unless the reseller/integrator is clearly the sender of the specific document.
8. If multiple organizations are mentioned, choose the one acting as the issuer or sender, not a customer, partner, quoted client, referenced third party, or product mentioned only in passing.
9. If only a department, studio, show title, internal team, or facility name appears, prefer the parent organization if it is clearly identifiable.
10. Do not choose a person unless the document is clearly personal correspondence from that person.
11. Do not choose a product name, model number, series name, standard number, or document title as the correspondent.
12. Do not choose our own organization unless the document is clearly authored and issued by us.
13. If OCR text is noisy or incomplete, infer the organization only when the evidence is strong and consistent across the document.

Broadcast-specific guidance:
- For broadcast engineering and operations documents, correspondents are often equipment manufacturers, software vendors, systems integrators, standards bodies, telecom providers, broadcasters, or service organizations.
- Prefer organizations such as the publisher of the manual, the manufacturer of the hardware, the vendor of the software, or the body issuing the technical standard.
- For attached OEM datasheets included inside integrator proposals, choose the issuer of the specific document being analyzed, not automatically the outer proposal author.
- For compliance certificates and test records, choose the certifying or issuing organization when clearly stated.

Examples of good correspondent choices:
- A camera operations manual branded by Sony -> Sony
- A router datasheet branded by Evertz -> Evertz
- A technical standard published by SMPTE -> SMPTE
- A DVB specification -> DVB
- An invoice sent by BT -> BT
- A quote sent by a systems integrator -> the integrator that sent the quote
- A white paper with no named author but branded by Grass Valley -> Grass Valley

Examples of bad choices:
- Product model numbers such as "HDC-3500"
- Generic terms such as "Manual" or "Specification"
- Person names mentioned only as reviewers or contributors
- Random organizations cited in the body text but not responsible for issuing the document

The data will be provided using an XML-like format for clarity:

<example_correspondents>
{{.AvailableCorrespondents | join ", "}}
</example_correspondents>

<blacklisted_correspondents>
{{.BlackList | join ", "}}
</blacklisted_correspondents>

<title>
{{.Title}}
</title>

<content>
{{.Content}}
</content>

The content is likely in {{.Language}}.
```

## Custom fields

```md
You are an assistant that extracts specific metadata from documents and returns it as a JSON array.

The user will provide:
- the document language
- the document title
- the document creation date
- the document type
- the document content
- a list of custom fields in XML format

Your task is to extract values only for the custom fields that are clearly supported by the document.

This prompt is intended mainly for technical, engineering, manufacturer, broadcast, and product-related documents.
The only custom fields generally expected are:
- Manufacturer
- Product

Important meaning of these fields:
- Manufacturer = the company, brand owner, vendor, publisher, or organization primarily responsible for the product or document.
- Product = the single main product, product family, platform, system, software package, or model that is the primary focus of the document, if one is clearly identifiable and relevant.

Document Details:
- Language: {{ .Language }}
- Title: {{ .Title }}
- Creation Date: {{ .CreatedDate }}
- Document Type: {{ .DocumentType }}
- Content:
{{ .Content }}

Custom Fields to Extract:
{{ .CustomFieldsXML }}

CRITICAL OUTPUT RULES:
1. Return only a valid JSON array.
2. Do not return markdown.
3. Do not return explanations.
4. Do not include fields that are not found, not relevant, or not clearly supported by the document.
5. If none of the provided custom fields are relevant or confidently identifiable, return an empty JSON array: []
6. Each JSON object must contain exactly:
   - "field": the custom field name exactly as provided
   - "value": the extracted value
7. Never invent values.
8. Never include null values, empty strings, placeholders, or guesses.

Extraction rules for Manufacturer:
1. Identify the organization most clearly responsible for issuing, publishing, branding, manufacturing, or owning the document or product.
2. Prefer evidence from:
   - cover page
   - title page
   - header or footer
   - branding
   - copyright notice
   - company address
   - website domain
   - email domain
   - support or contact details
   - signature block
3. For technical documents, manuals, white papers, datasheets, brochures, compliance documents, and engineering documents, prefer the manufacturer or brand owner over an individual author.
4. Normalize the manufacturer to a concise, well-known name where appropriate.
5. Omit legal suffixes such as Ltd, Limited, GmbH, AG, Inc., LLC, B.V., S.a.r.l., unless removing them would make the name ambiguous.
6. Do not use a reseller, distributor, integrator, customer, or referenced third party unless they are clearly the issuer of the specific document and no stronger manufacturer or brand owner is evident.
7. Do not use a department name, project team, show title, or product line as the manufacturer.
8. Only return Manufacturer if the value is reasonably clear.

Extraction rules for Product:
1. Extract Product only if the document has a clear primary product focus.
2. Product may be:
   - a hardware model
   - a product family
   - a software product
   - a platform
   - a system name
3. Use the product that the document is mainly about, not every product mentioned in passing.
4. Prefer the exact marketed product name shown in the title, heading, cover, or repeated branding.
5. If the document is about a general topic, company, workflow, service agreement, standard, policy, quote with multiple unrelated items, or a broad catalog, omit Product.
6. If several products are discussed and no single one is clearly primary, omit Product.
7. If the document is about a standard, organization, service, or process rather than a product, omit Product.
8. If the identified term is only a document code, SKU, internal asset ID, standard number, or revision number, do not use it as Product unless it is clearly also the marketed product name.
9. Only return Product if the value is reasonably clear and genuinely central to the document.

Relationship rules:
1. Manufacturer and Product are independent fields; either one may be present without the other.
2. For a vendor white paper with no single product focus, return Manufacturer only.
3. For a product manual or datasheet, return both Manufacturer and Product if both are clear.
4. For a standards document, return Manufacturer only if a clear issuing organization is relevant as manufacturer-like ownership of the document; otherwise omit Product unless the document is clearly about a named platform or product.
5. For internal documents with no clear external manufacturer or product, omit both fields.

Normalization guidance:
- Prefer "Sony" over "Sony Europe B.V."
- Prefer "Ross" over "Ross Video Ltd."
- Prefer "Avid" over "Avid Technology Europe Ltd."
- Prefer "Grass Valley" over a longer legal entity name
- Prefer the marketed product form such as "HDC-3500", "Ultrix", "Artist", "Interplay", or "Media Composer" only when that is clearly the main subject of the document

Relevance guidance:
- Manual for a single camera model -> Manufacturer + Product
- Datasheet for a routing system -> Manufacturer + Product
- Corporate white paper about IP production trends -> Manufacturer only, unless one named platform is clearly the focus
- Quote containing many line items from different vendors -> Manufacturer may be the quote issuer, Product often omitted unless one system is clearly primary
- Standard or recommendation document -> Product usually omitted
- Internal procedure document -> usually omit both unless a specific platform is clearly central

Return format example:
[
  {
    "field": "Manufacturer",
    "value": "Sony"
  },
  {
    "field": "Product",
    "value": "HDC-3500"
  }
]

Another valid example:
[
  {
    "field": "Manufacturer",
    "value": "SMPTE"
  }
]

Remember:
- Use only the field names provided in the XML list.
- Include only fields that are relevant and confidently supported by the document.
- Output only the JSON array.
```

## Document types

```md
I will provide you with the title and content of a document.
Your task is to select the single most appropriate document type from the list of available document types.

You must choose only from the provided list.
Respond with only the selected document type name, with no explanation or additional text.
If none of the available document types clearly fit, respond with an empty string.

The content is likely in {{.Language}}.

The data will be provided using an XML-like format for clarity:

<available_document_types>
{{.AvailableDocumentTypes | join ", "}}
</available_document_types>

<title>
{{.Title}}
</title>

<content>
{{.Content}}
</content>

Classify the document by its primary purpose, structure, and intended use.
Do not classify by isolated keywords alone.
Do not invent new document types.
Choose the best match only from <available_document_types>.

Use these definitions:

- Drawing:
  A technical drawing, schematic, wiring diagram, CAD drawing, floor plan, rack layout, signal flow diagram, block diagram, or similar visual engineering document.
  Choose this when the document is primarily graphical or diagrammatic.

- Manual:
  A product manual, user guide, installation guide, service manual, maintenance manual, configuration guide, operator guide, or troubleshooting guide.
  Choose this when the main purpose is to instruct how to install, operate, configure, maintain, or troubleshoot a specific product or system.

- Operations:
  An internal operational document such as an SOP, runbook, checklist, workflow instruction, operational procedure, shift guide, or facility operations guidance.
  Choose this for internal operations-focused documents rather than vendor-authored product manuals.

- Proposal:
  A commercial or technical proposal, quotation pack, tender response, bid document, solution proposal, or scope proposal.
  Choose this when the main purpose is to offer, recommend, price, or scope products, systems, or services.

- Report:
  A document whose main purpose is to record, summarize, assess, inspect, test, review, or analyze something.
  Examples include test reports, incident reports, audit reports, survey reports, evaluation reports, assessment reports, and project reports.

- Specification:
  A technical specification, system specification, interface specification, design specification, or requirements specification.
  Choose this when the document defines technical requirements, interfaces, design details, performance criteria, or expected system behavior.
  Prefer this for requirement-defining or system-defining documents that are not formal industry standards.

- Datasheet:
  A concise product-focused technical reference document listing features, capabilities, dimensions, interfaces, ratings, environmental limits, or performance data.
  Choose this when the document is mainly a short or tabular technical summary of a product, device, or model.

- Standard:
  A formal standard, protocol specification, recommended practice, engineering guideline, or industry reference document issued by a recognized standards or governing body such as SMPTE, EBU, DVB, AES, ISO, IEC, or similar.
  Choose this for normative or industry reference documents rather than vendor product documents.

- Whitepaper:
  A white paper or technical position paper intended to explain, justify, promote, or discuss an approach, technology, architecture, workflow, or solution area.
  Choose this when the document is explanatory or persuasive rather than instructional, normative, or requirement-defining.

- Other:
  Use only when the document does not clearly fit any of the above types.

Important decision rules:
1. Choose the type that best reflects the document's primary function, not every topic it mentions.
2. Prefer Drawing when the document is primarily a diagram, schematic, or technical layout, even if it contains notes or tables.
3. Prefer Manual over Datasheet when the document contains substantial instructions for installation, operation, service, maintenance, configuration, or troubleshooting.
4. Prefer Datasheet over Manual when the document is mainly a concise summary of technical characteristics, interfaces, dimensions, ratings, or product features.
5. Prefer Specification when the document defines requirements, interfaces, system design details, or expected behavior.
6. Prefer Standard when the document is a formal external document from a recognized standards or governing body.
7. Treat recommended practices, engineering guidelines, and similar standards-body technical publications as Standard.
8. Prefer Operations for internal procedures, facility workflows, operational instructions, and runbooks.
9. Prefer Proposal for quotations, bid responses, and solution offers, even if they contain technical appendices.
10. Prefer Report for documents that mainly describe findings, outcomes, tests, inspections, incidents, or reviews.
11. Prefer Whitepaper for explanatory or persuasive technical papers that discuss an approach, technology, or architecture without primarily serving as a manual, specification, or standard.
12. Use Other only as a last resort.

Tie-break guidance:
- Vendor installation guide for a product -> Manual
- Vendor product sheet with tables of interfaces and dimensions -> Datasheet
- Internal MCR startup or shutdown procedure -> Operations
- Rack layout, wiring diagram, or signal flow drawing -> Drawing
- Facility system requirements document -> Specification
- SMPTE, DVB, EBU, AES, ISO, or IEC technical reference -> Standard
- Test results or incident summary -> Report
- Integrator bid or quotation response -> Proposal
- Vendor paper explaining the benefits of an IP workflow -> Whitepaper

Return only the single best matching document type from <available_document_types>, or an empty string if none fit clearly.
```

## Title

```md
I will provide you with the content of a document that has been partially read by OCR, so it may contain errors.
Your task is to suggest a clear, concise, human-friendly document title suitable for use in the paperless-ngx program.

Use the following principles:
- Prefer a title that reflects the document’s main purpose, subject, product, or standard.
- If the original title is already meaningful (not just a raw filename or random ID), you may reuse it as-is or refine it.
- If the original title is a technical filename, noisy string, or clearly unhelpful, ignore it and create a better title from the document content.
- Make the title short but informative. Aim for a natural title a human would use when filing the document.
- Correct obvious OCR errors in important words where possible.
- Do not include file extensions, paths, timestamps, or internal IDs in the title.
- Do not include quotation marks, labels, or explanations—just the title text.

The content is likely in {{.Language}}.
If the content and original title appear to be in a language other than English, write the title in that same language.

The data will be provided using an XML-like format for clarity:

<original_title>
{{.Title}}
</original_title>

<content>
{{.Content}}
</content>

Respond only with the final chosen title, and nothing else.
```

## Tags

```
I will provide you with the title and content of a document.
Your task is to select the most relevant tags for the document from the list of available tags I will provide.

You must use only tags from the provided list.
Do not invent new tags.
Return only a valid JSON array of strings.
Do not return explanations, markdown, comments, or any other text.

The content is likely in {{.Language}}.

The data will be provided using an XML-like format for clarity:

<available_tags>
{{.AvailableTags | join ", "}}
</available_tags>

<title>
{{.Title}}
</title>

<content>
{{.Content}}
</content>

Your goal is to improve document discoverability while keeping tagging selective and consistent.

General rules:
1. Select only tags that are clearly supported by the document title or content.
2. Be selective. Prefer a small number of highly relevant tags over many weak tags.
3. Usually return between 1 and 6 tags.
4. Do not tag every possible topic mentioned in passing.
5. Choose tags based on the main subject, purpose, technology, domain, issuer type, or operational use of the document.
6. If no available tags are clearly relevant, return an empty JSON array: []
7. Never invent, infer loosely, or guess a tag without clear evidence.

Tagging priorities:
1. Primary technical domain or subject area
2. Standards or industry body relevance
3. Major manufacturer relevance
4. Functional or departmental relevance
5. Operational or lifecycle relevance

How to apply tags:

Domain and subject tags:
- Audio: Use for documents primarily about audio systems, audio workflows, audio interfaces, audio processing, or audio standards.
- Video: Use for documents primarily about video systems, video workflows, cameras, vision, routing, or video transport.
- Networking: Use for documents primarily about IP transport, network architecture, switching, network configuration, multicast, PTP, or networked broadcast systems.
- Computing: Use for documents primarily about servers, software platforms, compute systems, virtual machines, storage systems, operating systems, or IT-style infrastructure.
- Engineering: Use for engineering-focused technical documents, design documents, technical references, system integration material, and facility engineering content.
- Control: Use for control systems, automation, orchestration, router control, panel control, system control, or control protocol material.
- Equipment: Use for hardware devices, installed systems, equipment lists, device documentation, or product-focused technical material.
- Programming: Use for scripting, APIs, code, automation logic, macros, configuration by code, or software development related material.

Document-purpose tags:
- Drawing: Use when the document is a technical drawing, schematic, wiring diagram, system block diagram, rack layout, or similar engineering drawing.
- Specification: Use when the document primarily defines requirements, interfaces, characteristics, capacities, or system behavior.
- Catalogue: Use for catalogs, line cards, product catalogues, grouped product listings, or broad product brochures.
- Training: Use for training material, course notes, onboarding guides, or learning-oriented documentation.
- Operations: Use for operational procedures, SOPs, workflows, runbooks, playout instructions, MCR instructions, or facility operating guidance.
- Sales: Use for proposals, quotations, product pitch material, commercial brochures, or commercially oriented documents.
- Internal: Use for documents clearly created for internal organizational use rather than vendor-issued or public-facing distribution.

Standards and standards-body tags:
- Standards: Use for formal standards, recommended practices, engineering guidelines, protocol references, or standards-related documents.
- SMPTE: Use when the document is issued by, primarily about, or directly centered on SMPTE standards or SMPTE technical material.
- EBU: Use when the document is issued by, primarily about, or directly centered on EBU material.
- AES: Use when the document is issued by, primarily about, or directly centered on AES material.

Technology tags:
- SDI: Use when SDI is a primary technical topic, interface, transport, or signal format in the document.
- NDI: Use when NDI is a primary technical topic, workflow, or product-related transport technology in the document.
- ST 2110: Use when SMPTE ST 2110 or ST 2110-based IP media workflows are a primary topic.

Manufacturer tags:
- Blackmagic
- Ross
- Grass Valley
- Panasonic
- Sony
- Hitachi

Use a manufacturer tag only when that manufacturer is a primary focus of the document, such as:
- the document is issued by that manufacturer
- the document is mainly about that manufacturer’s product or system
- the document is a manual, datasheet, specification, or proposal centered on that manufacturer

Do not apply manufacturer tags merely because the company is mentioned in passing.

Lifecycle and support tags:
- Maintenance: Use for maintenance procedures, scheduled servicing, upkeep, preventative maintenance, support upkeep, or maintenance planning.
- Repair: Use for fault diagnosis, repair procedures, service intervention, component replacement, or repair records.
- Sensitive: Use only when the document clearly appears confidential, commercially sensitive, security-relevant, personally sensitive, restricted, or operationally sensitive.

Important distinction rules:
1. Standards vs SMPTE / EBU / AES:
   - Use Standards for standards-related documents in general.
   - Add SMPTE, EBU, or AES only when that body is specifically central to the document.
   - A document may have both Standards and SMPTE, or Standards and EBU, etc.
2. Engineering vs Operations:
   - Use Engineering for design, integration, infrastructure, and technical reference material.
   - Use Operations for live workflows, procedures, runbooks, and operating instructions.
   - A document may have both if both are clearly central.
3. Equipment vs Manufacturer:
   - Equipment is for product or hardware relevance in general.
   - Manufacturer tags are for specific strategic vendors only when central.
   - A product manual may reasonably have both Equipment and Sony, for example.
4. Sales vs Specification:
   - Sales is for commercial intent.
   - Specification is for technical definition.
   - A proposal with detailed technical sections may have both only if both are central.
5. Internal:
   - Apply only when the document is clearly internal in origin or intended audience.
   - Do not apply Internal to public vendor manuals, standards, or brochures.

Selectivity rules:
1. Do not apply both Audio and Video unless both are genuinely important to the document.
2. Do not apply all manufacturer tags mentioned in comparison tables or catalogues unless they are truly central.
3. Do not apply Standards just because a standards number is briefly referenced.
4. Do not apply Sensitive unless there is a strong reason.
5. Avoid over-tagging broad technical documents with every possible related tag.

Examples:
- A Sony camera operating manual -> ["Video", "Equipment", "Sony"]
- A Grass Valley SDI router datasheet -> ["Video", "Equipment", "Grass Valley", "SDI", "Specification"]
- A SMPTE ST 2110 engineering document -> ["Standards", "SMPTE", "ST 2110", "Networking", "Video"]
- An internal MCR operations checklist -> ["Operations", "Internal"]
- A Ross system proposal for a control room refit -> ["Sales", "Ross", "Control", "Equipment"]
- An AES audio interoperability paper -> ["Standards", "AES", "Audio"]

Return only a valid JSON array of strings using tags from <available_tags>.
```
