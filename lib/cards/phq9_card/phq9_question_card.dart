import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/phq9_card/phq9_question_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PHQ9QuestionCard extends BasicCard {
  final ValueChanged<int> onQuestionAnswered;

  PHQ9QuestionCard(PageContext pageContext, this.onQuestionAnswered) : super(pageContext);

  static List<DataCard> cards = [
    DataCard(
      uid: "phq9QuestionCard1",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-1.jpg?alt=media&token=574c107c-6176-4191-924a-3d95a9d49221",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-1.mp4?alt=media&token=4fd0273d-a1a5-42e2-8e24-5524d186f119",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step one",
        content: "Over the last two weeks have you felt little interest or pleasure in doing things?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard2",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-2.jpg?alt=media&token=638dd4f4-f798-434e-a43a-f524beee263d",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-2.mp4?alt=media&token=ccbef4a1-15fe-4e8c-a29e-377203b1c2a7",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step two",
        content: "Over the last two weeks have you been feeling down, depressed or hopeless?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard3",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-3.jpg?alt=media&token=0b81795f-3e7b-4392-b7e1-e4b916e1838f",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-3.mp4?alt=media&token=d20387a4-2ab0-41b5-821c-26241ac273b2",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step three",
        content: "Over the last two weeks have you had trouble falling/staying asleep, or sleeping too much?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard4",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-4.jpg?alt=media&token=842ee8b0-f9ab-4684-bc61-db8f2171b798",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-4.mp4?alt=media&token=daca8cda-7777-42db-b4e6-0abf4900e893",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step four",
        content: "Over the last two weeks have you been feeling tired or lacking in energy?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard5",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-4.jpg?alt=media&token=842ee8b0-f9ab-4684-bc61-db8f2171b798",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-5.mp4?alt=media&token=fda8b71b-2545-4200-8283-b9999cc551ba",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step five",
        content: "Over the last two weeks have you had a poor appetite or been overeating?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard6",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-6.jpg?alt=media&token=85759629-df91-4a27-9d09-7ae4bd63b668",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-6.mp4?alt=media&token=8d94d71d-598e-4ade-bf9d-f8b03c6f2676",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step six",
        content:
            "Over the last two weeks have you been feeling like a failure – that you let yourself or your family down?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard7",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-7.jpg?alt=media&token=ee871e23-b981-4a86-823f-f3b923bf9e7e",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-7.mp4?alt=media&token=f31f4c01-cbd4-4227-bb19-22750c23c735",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step seven",
        content:
            "Over the last two weeks have you had trouble concentrating on things, such as reading the newspaper or watching tv?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard8",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-8.jpg?alt=media&token=9914a0fe-72b1-4457-8d77-314ab7dac828",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-8.mp4?alt=media&token=dc328b00-3266-4ee7-8157-434630352571",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step height",
        content:
            "Over the last two weeks have you been moving or speaking so slowly that other people have noticed? Or the opposite, being fidgety and restless?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard9",
      type: "phq9_question",
      background: Background(
        image:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_images%2Fphq9-question-card-9.jpg?alt=media&token=abc667b7-7c93-4810-8b8e-48fc28f01675",
        video:
            "https://firebasestorage.googleapis.com/v0/b/aebeze-api.appspot.com/o/phq9_videos%2Fphq9-question-card-9.mp4?alt=media&token=cae58cb2-115b-42a5-9d86-f0cc4faf9dea",
        color: colorToString(AppColors.veryLightGrey),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step nine",
        content:
            "Over the last two weeks have you had thoughts that you would be better off dead or of hurting yourself?",
      ),
      messages: [
        Message(message: "Nearly every day"),
        Message(message: "More than half the days"),
        Message(message: "Several days"),
        Message(message: "Not at all"),
      ],
    ),
    DataCard(
      uid: "phq9QuestionCard10",
      type: "phq9_question",
      background: Background(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.offWhite, AppColors.lightCyan],
        ),
      ),
      placement: Placement(
        type: "top",
        textColor: colorToString(Colors.black),
        header: "Step ten",
        content:
            "If you’ve had any of these problems, how difficult have they made it to do your work, take care of things at home or get along with other people?",
      ),
      messages: [
        Message(message: "Extremely difficult"),
        Message(message: "Very difficult"),
        Message(message: "Somewhat difficult"),
        Message(message: "Not difficult at all"),
      ],
    ),
  ];

  @override
  BasicCardState createState() => _State(onQuestionAnswered);
}

class _State extends BasicCardState {
  final ValueChanged<int> onQuestionAnswered;

  _State(this.onQuestionAnswered);

  @override
  PHQ9QuestionCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) => PHQ9QuestionCardLayout(
      widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded, onQuestionAnswered);
}
