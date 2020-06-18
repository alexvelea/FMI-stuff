import django
import os
import sys
import json
import pytz

parent_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(1, parent_dir)

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'web.settings')

django.setup()

from django.utils.dateparse import parse_datetime
from external.models import *
import datetime


def read_from_file(file_name):
    with open(file_name) as json_file:
        return json.load(json_file)


def setup_contests(file_name):
    print('setting up contests')
    data = read_from_file(file_name)
    for contest in data:
        db_contest = Contest(
            origin=1,
            external_id=contest['id'],
            url='https://csacademy.com/contest/'+contest['name'],
            name=contest['longName'],
            start_time=parse_datetime(contest['startTime']))

        # setting up empty extra
        db_contest.extra['num_participants'] = 0
        db_contest.extra['num_problems'] = 0
        db_contest.set_extra()
        db_contest.save()


def setup_tasks(file_name):
    print('setting up tasks')
    data = read_from_file(file_name)
    for task in data:
        db_contest = Contest.objects.get(external_id=task['contestId'])

        db_task = Task(
            origin=1,
            external_id=task['id'],
            contest=db_contest,
            url='https://csacademy.com/contest/archive/task/'+task['name'],
            name=task['longName'],
            date_added=db_contest.start_time)

        # setting up empty extra
        db_task.extra['num_tried'] = 0
        db_task.extra['num_solved'] = 0
        db_task.extra['rating'] = 0
        db_task.set_extra()
        db_task.save()


def setup_users(file_name):
    print("setting up users")
    data = read_from_file(file_name)

    for user in data:
        if 'rating' not in user:
            continue

        if 'username' not in user['user'] or user['user']['username'] == '' or user['user']['username'] is None:
            continue

        external_user_id = user['user']['id']
        if User.objects.filter(external_id=external_user_id).count() == 0:
            # create user
            db_user = User(
                origin=1,
                external_id=external_user_id,
                username=user['user']['username'])

            # setting up empty extra
            db_user.extra['rating'] = 0
            db_user.set_extra()
            db_user.save()
        else:
            db_user = User.objects.get(external_id=external_user_id)

        db_contest = Contest.objects.get(external_id=user['contestId'])
        db_contest.extra['num_participants'] += 1
        db_contest.set_extra()
        db_contest.save()

        db_contest_user = ContestUser(contest=db_contest, user=db_user)

        # setting up empty extra
        db_contest_user.extra['rating_before'] = user['oldRating']
        db_contest_user.extra['rating_after'] = user['rating']
        db_contest_user.extra['num_problems_solved'] = 0
        db_contest_user.extra['num_problems'] = 0
        db_contest_user.extra['rank'] = user["rank"]
        db_contest_user.extra['num_participated_in_contest'] = 0

        for task_id in user['scores']:
            db_task = Task.objects.get(external_id=task_id)
            db_task.extra['num_tried'] += 1

            if user['scores'][task_id]['score'] != 1.0:
                db_task.save()
                continue

            db_contest_user.extra['num_problems_solved'] += 1
            db_task.extra['num_solved'] += 1
            db_task.set_extra()
            db_task.save()

            db_user_task = UserTask(
                user=db_user,
                task=db_task,
                solved_time=pytz.utc.localize(datetime.datetime.fromtimestamp(user['scores'][task_id]['scoreTime'])))
            # setting up empty extra
            db_user_task.set_extra()
            db_user_task.save()

        db_contest_user.set_extra()
        db_contest_user.save()


def setup_user_statistics():
    print("setting up stats")
    all_contests = list(Contest.objects.all())
    all_contests = sorted(all_contests, key=lambda x: x.start_time)
    for contest in all_contests:
        all_tasks = Task.objects.filter(contest=contest).all()

        all_users = list(ContestUser.objects.filter(contest=contest).prefetch_related('user'))
        for contest_user in all_users:
            contest_user.extra['num_problems'] = len(all_tasks)
            contest_user.extra['num_participated_in_contest'] = len(all_users)
            contest_user.set_extra()
            contest_user.save()

            contest_user.user.extra['rating'] = contest_user.extra['rating_after']
            contest_user.user.set_extra()
            contest_user.user.save()


def main():
    if len(sys.argv) == 1:
        print('Usage: python3 ./scripts/import_csa_data.py path_to_data_folder')
        return

    setup_contests(sys.argv[1] + '/contests.json')
    setup_tasks(sys.argv[1] + '/contest_tasks.json')
    setup_users(sys.argv[1] + '/contest_users.json')
    setup_user_statistics()


main()
