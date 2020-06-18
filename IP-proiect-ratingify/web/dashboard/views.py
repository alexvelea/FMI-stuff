from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.views import View
from external.models import *

def dashboard(request, username):
    if User.objects.filter(username=username).count() == 0:
        Users = User.objects.order_by("username")
        users = []
        for x in Users:
            users.append(x.username)
        context = {
            'error': 'Previous searched user was not found.',
            'users': users,
        }
        return render(request, 'dashboard/index.html', context)

    context = {
        'username': username,
        'stats': {
            'data': [9, 3, 7, 9, 2, 7, 3],
            'labels': ["Backtracking", "Recursion", "Geometry", "Binary Search", "Graphs", "Math", "Strings"],
        },
        'recommendedProblems': [
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'EASY',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'EASY',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'EASY',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'MEDIUM',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'MEDIUM',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'MEDIUM',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'HARD',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'HARD',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
            {
                'url': '',
                'name': 'Fill the Glasses',
                'dateSolved': '02 Jun 2018, 08:34:20',
                'difficulty': 'HARD',
                'percentageSolved': '77%',
                'popularity': 'Very low',
            },
        ]
    }

    context['stats'] = {
        'data': [9, 3, 7, 9, 2, 7, 3],
        'labels': ["Backtracking", "Recursion", "Geometry", "Binary Search", "Graphs", "Math", "Strings"],
    }

    context['solvedInPastDays'] = {
        'data': [3, 4, 2, 6, 5, 7],
        'labels': [
            '08.03.2019',
            '12.03.2019',
            '16.03.2019',
            '20.03.2019',
            '24.03.2019',
            '28.03.2019',
        ],
    }
    context['previousContests'] = []

    db_user = User.objects.get(username=username)
    context['rating'] = int(db_user.extra['rating'])

    db_user_contests = ContestUser.objects.filter(user=db_user).prefetch_related('contest')
    past_user_contests = sorted(db_user_contests, key=lambda x: x.contest.start_time, reverse=True)[:5]

    for cu in past_user_contests:
        contest = cu.contest
        context['previousContests'].append({
            'url': contest.url,
            'name': contest.name,
            'rank': cu.extra['rank'],
            'participantsCount': cu.extra['num_participated_in_contest'],
            'problemsSolved': cu.extra['num_problems_solved'],
            'problemsCount': cu.extra['num_problems']
        })

    db_user_tasks = UserTask.objects.filter(user=db_user).prefetch_related('task')
    recent_tasks = sorted(db_user_tasks, key=lambda x: x.solved_time, reverse=True)[:5]

    context['lastSolvedProblems'] = []

    for ut in recent_tasks:
        task = ut.task
        context['lastSolvedProblems'].append({
            'url': task.url,
            'name': task.name,
            'dateSolved': ut.solved_time.strftime("%d %b %Y, %H:%M:%S"),
            'difficulty': 'EASY'
        })
    return render(request, 'dashboard/dashboard.html', context)


def index(request):
    Users = User.objects.order_by("username")
    users = []
    for x in Users:
        users.append(x.username)

    context = {
        #'error': 'Previous searched user was not found.',
        'users': users,
    }
    return render(request, 'dashboard/index.html', context)
