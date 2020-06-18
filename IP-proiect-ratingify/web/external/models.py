from django.db import models
import json

ORIGIN_TYPES = (
    (0, "Unknown"),
    (1, "CSAcademy")
)


class Contest(models.Model):
    origin = models.IntegerField(choices=ORIGIN_TYPES, default=0)
    external_id = models.IntegerField()

    url = models.TextField(default="", blank=True)
    name = models.TextField(default="", blank=True)
    start_time = models.DateTimeField()

    def __str__(self):
        return self.name

    extra_str = models.TextField(default="{}")

    @property
    def extra(self):
        if not hasattr(self, 'extra_json'):
            self.extra_json = json.loads(self.extra_str)
        return self.extra_json

    def set_extra(self):
        self.extra_str = json.dumps(self.extra)


class Task(models.Model):
    origin = models.IntegerField(choices=ORIGIN_TYPES, default=0)
    external_id = models.IntegerField()

    contest = models.ForeignKey("Contest", on_delete=models.SET_NULL, related_name="+", null=True, blank=True)

    url = models.TextField(default="", blank=True)
    name = models.TextField(default="", blank=True)
    date_added = models.DateTimeField()

    def __str__(self):
        return self.name

    extra_str = models.TextField(default="{}")

    @property
    def extra(self):
        if not hasattr(self, 'extra_json'):
            self.extra_json = json.loads(self.extra_str)
        return self.extra_json

    def set_extra(self):
        self.extra_str = json.dumps(self.extra)


class User(models.Model):
    origin = models.IntegerField(choices=ORIGIN_TYPES, default=0)
    external_id = models.IntegerField()

    username = models.TextField(default="", blank=True)

    def __str__(self):
        return self.username

    extra_str = models.TextField(default="{}")

    @property
    def extra(self):
        if not hasattr(self, 'extra_json'):
            self.extra_json = json.loads(self.extra_str)
        return self.extra_json

    def set_extra(self):
        self.extra_str = json.dumps(self.extra)


class UserTask(models.Model):
    user = models.ForeignKey("User", on_delete=models.SET_NULL, related_name="+", null=True, blank=True)
    task = models.ForeignKey("Task", on_delete=models.SET_NULL, related_name="+", null=True, blank=True)
    solved_time = models.DateTimeField()

    extra_str = models.TextField(default="{}")

    @property
    def extra(self):
        if not hasattr(self, 'extra_json'):
            self.extra_json = json.loads(self.extra_str)
        return self.extra_json

    def set_extra(self):
        self.extra_str = json.dumps(self.extra)


class ContestUser(models.Model):
    user = models.ForeignKey("User", on_delete=models.CASCADE, related_name="+")
    contest = models.ForeignKey("Contest", on_delete=models.CASCADE, related_name="+")

    extra_str = models.TextField(default="{}")

    @property
    def extra(self):
        if not hasattr(self, 'extra_json'):
            self.extra_json = json.loads(self.extra_str)
        return self.extra_json

    def set_extra(self):
        self.extra_str = json.dumps(self.extra)
