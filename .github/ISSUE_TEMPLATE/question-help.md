name: Question
description: Have question(s)?
title: "[Questions] Replace with your question"
labels: question
body:
- type: checkboxes
  attributes:
    label: Is there an existing issue/question for this?
    description: _Please search to see if an issue already exists for the bug you encountered. **I DON\'T MAKE THIS TICK BOX FOR COSMETIC.**_
    options:
    - label: I have searched the existing issues
      required: true

- type: dropdown
  attributes:
    label: Do you think this is a bug?
    description: _If you think this is a bug, please open a new issue with the bug template_
    multiple: false
    options:
      - ✅ Yes, I believe this is a bug. I will open a new issue with the bug template
      - ❌ No, I don't think this is a bug. I will explain below
  validations:
    required: true

- type: textarea
  attributes:
    label: My question
    description: _Please enter your question here_
  validations:
    required: true

- type: textarea
  attributes:
    label: Additional context
    description: _Um, anything else you want to say?_
  validations:
    required: false
