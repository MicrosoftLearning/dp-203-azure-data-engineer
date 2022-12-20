---
title: Online Hosted Instructions
permalink: index.html
layout: home
---

# Azure Data Engineering Exercises

The following exercises support the training modules on Microsoft Learn that support the [Microsoft Certified: Azure Data Engineer Associate](https://learn.microsoft.com/certifications/azure-data-engineer/) certification.

To complete these exercises, you'll need a [Microsoft Azure subscription](https://azure.microsoft.com/free) in which you have administrative access. For some exercises, you may also need access to a [Microsoft Power BI tenant](https://learn.microsoft.com/power-bi/fundamentals/service-self-service-signup-for-power-bi).

{% assign labs = site.pages | where_exp:"page", "page.url contains '/Instructions/Labs'" %}
| Exercise | In ILT, this is a... |
| --- | --- |
{% for activity in labs  %}| [{{ activity.lab.title }}{% if activity.lab.type %} - {{ activity.lab.type }}{% endif %}]({{ site.github.url }}{{ activity.url }}) | {{ activity.lab.ilt-use }} |
{% endfor %}
