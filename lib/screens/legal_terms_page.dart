import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/get_color.dart';

class LegalTermsPage extends StatefulWidget {
  static const title = 'Terms & Conditions';

  @override
  _LegalTermsPageState createState() => _LegalTermsPageState();
}

class _LegalTermsPageState extends State<LegalTermsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollNavBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    _scrollNavBarController.removeListener(() {});
    super.dispose();
  }

  void myScroll() async {
    _scrollNavBarController.addListener(() {
      if (_scrollNavBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          hideBottomBar();
        }
      }
      if (_scrollNavBarController.offset <= 0) {
        if (isScrollingDown) {
          isScrollingDown = false;
          showBottomBar();
        }
      }
    });
  }

  void showBottomBar() {
    setState(() {
      _showAppbar = true;
    });
  }

  void hideBottomBar() {
    setState(() {
      _showAppbar = false;
    });
  }

  Widget navBarReplacement() {
    return _showAppbar ? SizedBox() : SizedBox(height: 44);
  }

  Widget subtitle(int number, String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number.toString() + '. ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget numberedSection(double number, String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number.toString() + '. ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget letterSection(double number, String letter, String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number.toString() + '. ',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: getThemeColor(context)),
            ),
            Flexible(
              child: Text(
                '(' + letter + ') ' + text,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget indentedBodyText(String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 44),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget bodyText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 17),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
          controller: _scrollNavBarController,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24),
          children: <Widget>[
            navBarReplacement(),
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text('Terms & Conditions',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 40,
            ),
            subtitle(1, "About the Application"),
            SizedBox(
              height: 5,
            ),
            numberedSection(1.1,
                "Welcome to Dollar Feeds (the 'Application' or 'App'). The Application provides you with an opportunity to browse various promotions, vouchers, coupons and other offers that have been listed for use through the Application (the 'Offers'). The Application provides this service by way of granting you access to the content on the Application (the 'Services')."),
            numberedSection(1.2,
                "The Application is operated by Dollar Feast (ABN 52 735 628 008 ). Access to and use of the Application, or any of its associated Products or Services, is provided by Dollar Feast. Please read these terms and conditions (the 'Terms') carefully. By using, browsing and/or reading the Application, this signifies that you have read, understood and agree to be bound by the Terms. If you do not agree with the Terms, you must cease usage of the Application, or any of its Services, immediately."),
            numberedSection(1.3,
                "Dollar Feast reserves the right to review and change any of the Terms by updating this page at its sole discretion. When Dollar Feast updates the Terms, it will use reasonable endeavours to provide you with notice of updates to the Terms. Any changes to the Terms take immediate effect from the date of their publication."),
            SizedBox(
              height: 20,
            ),
            subtitle(2, "Acceptance of the Terms"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "You accept the Terms by using or browsing the Application. You may also accept the Terms by clicking to accept or agree to the Terms where this option is made available to you by Dollar Feast in the user interface."),
            SizedBox(
              height: 20,
            ),
            subtitle(3, "Registration to use Additional App Services"),
            SizedBox(
              height: 5,
            ),
            numberedSection(3.1,
                'In order to access the additional Application Services, such as saving offers, you must first register as a user of the Application (creating an "Account"). As part of the registration process, you may be required to provide personal information about yourself (such as identification or contact details), including email addresses and passwords.'),
            numberedSection(3.2,
                "You warrant that any information you give to Dollar Feast in the course of completing the registration process will always be accurate, correct and up todate."),
            numberedSection(3.3,
                "Once you have completed the registration process, you will be a registered member of the Application ('Member') and agree to be bound by the Terms. As a Member you will be granted immediate access to the Services."),
            numberedSection(3.4,
                "You may not use the Services and may not accept the Terms if:"),
            letterSection(3.4, "a",
                "you are not of legal age to form a binding contract with Dollar Feast; or"),
            letterSection(3.4, "b",
                "you are a person barred from receiving the Services under the laws of Australia or other countries including the country in which you are resident or from which you use the Services."),
            SizedBox(
              height: 20,
            ),
            subtitle(4, "Your Obligations as a Member"),
            SizedBox(
              height: 5,
            ),
            numberedSection(4.1,
                "As a Member, you agree to comply with the following: You will use the Services only for purposes that are permitted by:"),
            letterSection(4.1, "a", "the Terms;"),
            letterSection(4.1, "b",
                "any applicable law, regulation or generally accepted practices or guidelines in the relevant jurisdictions"),
            letterSection(4.1, "c",
                "you have the sole responsibility for protecting the confidentiality of your password and/or email address. Use of your password by any other person may result in the immediate cancellation of the Services;"),
            letterSection(4.1, "d",
                "any use of your registration information by any other person, or third parties, is strictly prohibited. You agree to immediately notify Dollar Feast of any unauthorised use of your password or email address or any breach of security of which you have become aware;"),
            letterSection(4.1, "e",
                "access and use of the Application is limited, non-transferable and allows for the sole use of the Application by you for the purposes of Dollar Feast providing the Services;"),
            letterSection(4.1, "f",
                "you will not use the Application for any illegal and/or unauthorised use which includes collecting email addresses of Members by electronic or other means for the purpose of sending unsolicited email or unauthorised framing of or linking to the Application;"),
            letterSection(4.1, "g",
                "you agree that commercial advertisements, affiliate links, and other forms of solicitation may be removed from the Application without notice and may result in termination of Accounts. Appropriate legal action will be taken by Dollar Feast for any illegal or unauthorised use of the Application; and"),
            letterSection(4.1, "h",
                "you acknowledge and agree that any automated use of the Application or its Services is prohibited."),
            SizedBox(
              height: 20,
            ),
            subtitle(5, "Limitation of Liability"),
            SizedBox(
              height: 5,
            ),
            numberedSection(5.1,
                "Offers listed in the Application refer to vouchers, coupons and other promotions are not created or offered by Dollar Feast, which only provides information regarding promotions offered by restaurants and other businesses. As such, the offers listed in the Application are subject to their own Terms and Conditions, seperate to those of the Application."),
            numberedSection(5.2,
                "Dollar Feast will not be liable for misuse of listed offers. It is the responsibility of Users to understand and agree to the Terms & Conditions of an offer before using it."),
            numberedSection(5.3,
                "Dollar Feast will not be liable for third party content posted to the Service, including but not limited to, user comments."),
            SizedBox(
              height: 20,
            ),
            subtitle(6, "Copyright and Intellectual Property"),
            SizedBox(
              height: 5,
            ),
            numberedSection(6.1,
                "The Application, the Services and all of the related offers of Dollar Feast are subject to copyright. The material on the Application is protected by copyright under the laws of Australia and through international treaties. Unless otherwise indicated, all rights (including copyright) in the site content and compilation of the Application (including text, graphics, logos, button icons, video images, audio clips and software) (the 'Content') are owned or controlled for these purposes, and are reserved by Dollar Feast, its contributors or other companies."),
            numberedSection(6.2,
                "Dollar Feast retains all rights, title and interest in and to the Application and all related content. Nothing you do on or in relation to the Application will transfer to you:"),
            letterSection(6.2, "a",
                "the business name, trading name, domain name, trade mark, industrial design, patent, registered design or copyright of Dollar Feast; or"),
            letterSection(6.2, "b",
                "the right to use or exploit a business name, trading name, domain name, trade mark or industrial design; or"),
            letterSection(6.2, "c",
                "a system or process that is the subject of a patent, registered design or copyright (or an adaptation or modification of such a system or process)."),
            numberedSection(6.3,
                "You may not, without the prior written permission of Dollar Feast and the permission of any other relevant rights owners: broadcast, republish, upload to a third party, transmit, post, distribute, show or play in public, adapt or change in any way the Content or third party content for any purpose. This prohibition does not extend to materials on the Application, which are freely available for reuse or are in the public domain."),
            SizedBox(
              height: 20,
            ),
            subtitle(7, "Privacy"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "Dollar Feast takes your privacy seriously and any information provided through your use of the Application and/or the Services are subject to Dollar Feast's Privacy Policy, which is available on the Application."),
            SizedBox(
              height: 20,
            ),
            subtitle(8, "General Disclaimer"),
            SizedBox(
              height: 5,
            ),
            numberedSection(8.1, "You acknowledge that Dollar Feast does not make any terms, guarantees, warranties, representations or conditions whatsoever regarding the Offers other than provided for pursuant to these Terms."),
            numberedSection(8.2, "Nothing in these Terms limits or excludes any guarantees, warranties, representations or conditions implied or imposed by law, including the Australian Consumer Law (or any liability under them) which by law may not be limited or excluded."),
            numberedSection(8.3, "Subject to this clause, and to the extent permitted by law:"),
            letterSection(8.3, "a", "all terms, guarantees, warranties, representations or conditions which are not expressly stated in these Terms are excluded; and"),
            letterSection(8.3, "b", "Dollar Feast will not be liable for any special, indirect or consequential loss or damage (unless such loss or damage is reasonably foreseeable resulting from our failure to meet an applicable Consumer Guarantee), loss of profit or opportunity, or damage to goodwill arising out of or in connection with the Services or these Terms (including as a result of not being able to use the Services or the late supply of the Services), whether at common law, under contract, tort (including negligence), in equity, pursuant to statute or otherwise."),
            numberedSection(8.4, 'Use of the Application, the Services, and any of the products of Dollar Feast is at your own risk. Everything on the Application, the Services of Dollar Feast and the third party Offers listed, are provided to you on an "as is"and "as available" basis, without warranty or condition of any kind. None of theaffiliates, directors, officers, employees, agents, contributors, third party content providers or licensors of Dollar Feast make any express or implied representation or warranty about its Content or any offers or Services referred to on the Application. This includes (but is not restricted to) loss or damage you might suffer as a result of any of the following:'),
            numberedSection(8.4, 'Use of the Application, the Services, and any of the products of Dollar Feast is at your own risk. Everything on the Application, the  Services of Dollar Feast and the third party Offers, are provided to you on an "as is"and "as available" basis, without warranty or condition of any kind. None of the affiliates, directors, officers, employees, agents, contributors, third party content providers or licensors of Dollar Feast make any express or implied representation or warranty about its Content or any offers or Services referred to on the Application. This includes (but is not restricted to) loss or damage you might suffer as a result of any of the following:'),
            letterSection(8.4, "a", "failure of performance, error, omission, interruption, deletion, defect, failure to correct defects, delay in operation or transmission, computer virus or other harmful component, loss of data, communication line failure, unlawful third party conduct, or theft, destruction, alteration or unauthorised access to records;"),
            letterSection(8.4, "b", "the accuracy, suitability or currency of any information on the Application, the Service, or any of its Content related products (including third party material and advertisements on the Application);"),
            letterSection(8.4, "c", "costs incurred as a result of you using the Application, the Services or any of the Offers;"),
            letterSection(8.4, "d", "the Content or operation in respect to links which are provided for the User's convenience;"),
            letterSection(8.4, "e", "any failure to complete a transaction, or any loss arising from e-commerce transacted on the Application; or"),
            letterSection(8.4, "f", "any defamatory, threatening, offensive or unlawful conduct of third parties or publication of any materials relating to or constituting such conduct."),
            SizedBox(
              height: 20,
            ),
            subtitle(9, "Competitors"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "If you are in the business of providing similar Services for the purpose of providing them to users for a commercial gain, whether business users or domestic users, then you are a competitor of Dollar Feast. Competitors are not permitted to use or access any information or content on our Application. This includes “crawling” the Application or otherwise using any automated means (including bots, scrapers, and spiders) to view, access, or collect information from Dollar Feast. If you breach this provision, Dollar Feast will hold you fully responsible for any loss that we may sustain and hold you accountable for all profits that you might make from such a breach."),
            SizedBox(
              height: 20,
            ),
            subtitle(10, "Termination of Contract"),
            SizedBox(
              height: 5,
            ),
            numberedSection(10.1,
                "The Terms will continue to apply until terminated by either you or by Dollar Feast as set out below."),
            numberedSection(
                10.2, "If you want to terminate the Terms, you may do so by:"),
            letterSection(10.2, "a", "notifying Dollar Feast at any time; and"),
            letterSection(10.2, "b",
                "closing your accounts for all of the Services which you use, where Dollar Feast has made this option available to you."),
            indentedBodyText(
                "Your notice should be sent, in writing, to Dollar Feast via our email at dollarfeeds@gmail.com."),
            numberedSection(10.3,
                "Dollar Feast may at any time, terminate the Terms with you if:"),
            numberedSection(10.4,
                "Subject to local applicable laws, Dollar Feast reserves the right to discontinue or cancel your membership to the Application at any time and may suspend or deny, in its sole discretion, your access to all or any portion of the Application or the Services without notice if you breach any provision of the Terms or any applicable law or if your conduct impacts Dollar Feast's name or reputation or violates the rights of those of another party."),
            numberedSection(10.5,
                "When the Terms come to an end, all of the legal rights, obligations and liabilities that you and Dollar Feast have benefited from, been subject to (or which have accrued over time whilst the Terms have been in force) or which are expressed to continue indefinitely, shall be unaffected by this cessation, and the provisions of this clause shall continue to apply to such rights, obligations and liabilities indefinitely."),
            SizedBox(
              height: 20,
            ),
            subtitle(11, "Indemnity"),
            SizedBox(
              height: 5,
            ),
            numberedSection(11.1,
                "You agree to indemnify Dollar Feast, its affiliates, employees, agents, contributors, third party content providers and licensors from and against:"),
            letterSection(11.1, "a",
                "all actions, suits, claims, demands, liabilities, costs, expenses, loss and damage (including legal fees on a full indemnity basis) incurred, suffered or arising out of or in connection with any Content you post through the Application;"),
            letterSection(11.1, "b",
                "any direct or indirect consequences of you accessing, using or transacting on the Application or attempts to do so and any breach by you or your agents of these Terms; and/or"),
            letterSection(11.1, "c", "any breach of the Terms."),
            SizedBox(
              height: 20,
            ),
            subtitle(12, "Venue and Jurisdiction"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "The Services offered by Dollar Feast are intended to be viewed by residents of Australia. In the event of any dispute arising out of or in relation to the Application, you agree that the exclusive venue for resolving any dispute shall be in the courts of Queensland, Australia."),
            SizedBox(
              height: 20,
            ),
            subtitle(13, "Governing Law"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "The Terms are governed by the laws of Queensland, Australia. Any dispute, controversy, proceeding or claim of whatever nature arising out of or in any way relating to the Terms and the rights created hereby shall be governed, interpreted and construed by, under and pursuant to the laws of Queensland, Australia, without reference to conflict of law principles, notwithstanding mandatory rules. The validity of this governing law clause is not contested. The Terms shall be binding to the benefit of the parties hereto and their successors and assigns."),
            SizedBox(
              height: 20,
            ),
            subtitle(14, "Independent Legal Advice"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "Both parties confirm and declare that the provisions of the Terms are fair and reasonable and both parties having taken the opportunity to obtain independent legal advice and declare the Terms are not against public policy on the grounds of inequality or bargaining power or general grounds of restraint of trade"),
            SizedBox(
              height: 20,
            ),
            subtitle(15, "Dispute Resolution"),
            SizedBox(
              height: 5,
            ),
            numberedSection(14.1,
                "Compulsory:\nIf a dispute arises out of or relates to the Terms, either party may not commence any Tribunal or Court proceedings in relation to the dispute, unless the following clauses have been complied with (except where urgent interlocutory relief is sought)."),
            numberedSection(14.2,
                "Notice:\nA party to the Terms claiming a dispute ('Dispute') has arisen under the Terms, must give written notice to the other party detailing the nature of the dispute, the desired outcome and the action required to settle the Dispute."),
            numberedSection(14.3,
                "Resolution:\nOn receipt of that notice ('NoticeNotice') by that other party, the parties to the Terms ('Parties') must:"),
            letterSection(14.3, "a",
                "Within ...... days of the Notice endeavour in good faith to resolve the Dispute expeditiously by negotiation or such other means upon which they may mutually agree;"),
            letterSection(14.3, "b",
                "If for any reason whatsoever, ...... days after the date of the Notice, the Dispute has not been resolved, the Parties must either agree upon selection of a mediator or request that an appropriate mediator beappointed by the President of the ...... or his or her nominee;"),
            letterSection(14.3, "c",
                "The Parties are equally liable for the fees and reasonable expenses of a mediator and the cost of the venue of the mediation and without limiting the foregoing undertake to pay any amounts requested by the mediator as a pre-condition to the mediation commencing. The Parties must each pay their own costs associated with the mediation;"),
            letterSection(
                14.3, "d", "The mediation will be held in ......, Australia."),
            numberedSection(14.4,
                'Confidential:\nAll communications concerning negotiations made by the Parties arising out of and in connection with this dispute resolution clause are confidential and to the extent possible, must be treated as "without prejudice" negotiations for the purpose of applicable laws of evidence.'),
            numberedSection(14.5,
                "Termination of Mediation:\nIf ...... have elapsed after the start of a mediation of the Dispute and the Dispute has not been resolved, either Party may ask the mediator to terminate the mediation and the mediator must do so."),
            SizedBox(
              height: 20,
            ),
            subtitle(16, "Severance"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "If any part of these Terms is found to be void or unenforceable by a Court of competent jurisdiction, that part shall be severed and the rest of the Terms shall remain in force."),
            SizedBox(
              height: 40,
            ),
          ]),
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: _showAppbar
          ? CupertinoNavigationBar(
              backgroundColor: getThemeColor(context),
              border: Border(bottom: BorderSide(color: getThemeColor(context))))
          : PreferredSize(
              child: Container(),
              preferredSize: Size(0.0, 0.0),
            ),
      body: _buildBody(context),
    );
  }
}
