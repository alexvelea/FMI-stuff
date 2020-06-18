from sklearn.naive_bayes import GaussianNB

def get_median(classifier):
    for i in range(3000):
        probability = classifier.predict_proba([[i]])[0][1]
        if probability > 0.5
            return i

def problem_classifier(rating, solved):
    gnb = GaussianNB()
    gnb.fit(rating, solved)
    median = get_median(gnb)
    return (median, gnb)